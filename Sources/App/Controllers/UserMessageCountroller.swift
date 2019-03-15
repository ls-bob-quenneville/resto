//
//  UserMessageCountroller.swift
//  App
//
//  Created by Bob Quenneville on 2019-01-09.
//

import FluentSQLite
import Vapor

final class UserMessageController {

    func create(_ req: Request) throws -> Future<HTTPStatus> {

        let message = req.content.get(Message.self, at: "message").flatMap { message -> Future<Message> in
            return message.save(on: req)
        }

        let users = req.content.get([Int].self, at: "userIds").flatMap { ids in

            req.withPooledConnection(to: .sqlite) { connection -> Future<[User]> in
                    return connection.raw("""
                                SELECT * FROM User WHERE OID IN (\(ids.compactMap({id in String(id)}).joined(separator: ",")));
                            """).all(decoding: User.self)
            }
        }

        return flatMap(to: HTTPStatus.self, message, users) { message, users in

            let messageId = try message.requireID()

            let userMessages = try users.compactMap { user -> Future<UserMessage> in

                let userId = try user.requireID()

                let userMessage = UserMessage(userId: userId, messageId: messageId)
                userMessage.new = true

                return userMessage.save(on: req)
            }

            return req.future(userMessages).transform(to: .ok)
        }
    }

    func messages(_ req: Request) throws -> Future<[Message]> {

        let userOid = try req.parameters.next(Int.self)

        return User.findUser(using: req, with: userOid).flatMap { user in
                return try user.messages.query(on: req).all()
        }
    }

    func newMessages(_ req: Request) throws -> Future<Int> {

        let userOid = try req.parameters.next(Int.self)

        return User.findUser(using: req, with: userOid).flatMap { user in
                return try user.messages.pivots(on: req).filter(\UserMessage.new, .equal, true).count()
        }
    }

    func readMessage(_ req: Request) throws -> Future<Message> {

        let userOid = try req.parameters.next(Int.self)
        let messageId = try req.parameters.next(Int.self)

        return User.findUser(using: req, with: userOid).flatMap { user in

            return try flatMap(to: Message.self,
                               self.markUserMessageAsRead(req, user: user, for: messageId),
                               self.getMessage(req, user: user, for: messageId)) { userMessage, message in

                    return req.future(message)
            }
        }
    }

    func markUserMessageAsRead(_ req: Request, user: User, for messageId: Int) throws -> Future<UserMessage> {

        return try user.messages.pivots(on: req)
                                .filter(\UserMessage.messageId, .equal, messageId)
                                .first()
                                .unwrap(or: Abort(.notFound))
                                .flatMap({ userMessage in
                                        userMessage.new = false
                                        return userMessage.update(on: req)
                                })
    }

    func getMessage(_ req: Request, user: User, for messageId: Int) throws -> Future<Message> {
        return try user.messages.query(on: req)
                                .filter(\Message.id, .equal, messageId)
                                .first()
                                .unwrap(or: Abort(.notFound))
    }

    func routes(_ router: Router) {

        router.post("userMessage", use: self.create)
        router.get("userMessage", Int.parameter, use: self.messages)
        router.get("userMessage", Int.parameter, "new", use: self.newMessages)
        router.get("userMessage", Int.parameter, Int.parameter, "read", use: self.readMessage)
    }
}

