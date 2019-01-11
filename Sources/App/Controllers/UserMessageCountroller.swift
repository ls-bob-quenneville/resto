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
            message.new = true
            return message.save(on: req)
        }

        let users = req.content.get([User.ID].self, at: "userIds").flatMap { ids in

            req.withPooledConnection(to: .sqlite) { connection -> Future<[User]> in
                    return connection.raw("""
                                SELECT * FROM User WHERE ID IN (\(ids.compactMap({id in String(id)}).joined(separator: ",")));
                            """).all(decoding: User.self)
            }
        }

        return flatMap(to: HTTPStatus.self, message, users) { message, users in

            let messageId = try message.requireID()

            let userMessages = try users.compactMap { user -> Future<UserMessage> in

                let userId = try user.requireID()

                return UserMessage(userId: userId, messageId: messageId).save(on: req)
            }

            return req.future(userMessages).transform(to: .ok)
        }
    }

    func messages(_ req: Request) throws -> Future<[Message]> {
        return try req.parameters.next(User.self).flatMap { user in
            return try user.messages.query(on: req).all()
        }
    }

    func newMessages(_ req: Request) throws -> Future<Int> {
        return try req.parameters.next(User.self).flatMap { user in
            return try user.messages.query(on: req).filter(\Message.new, .equal, true).count()
        }
    }

    func routes(_ router: Router) {

        router.post("userMessage", use: self.create)
        router.get("userMessage", User.parameter, use: self.messages)
        router.get("userMessage", User.parameter, "new", use: self.newMessages)
    }
}

