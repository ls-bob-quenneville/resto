//
//  MessageController.swift
//  App
//
//  Created by Bob Quenneville on 2019-01-09.
//

import Vapor

final class MessageController {

    func index(_ req: Request) throws -> Future<[Message]> {
        return Message.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Message> {
        return try req.content.decode(Message.self).flatMap { message in
            return message.save(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Message.self).flatMap { message in
            return message.delete(on: req)
            }.transform(to: .ok)
    }

    func routes(_ router: Router) {

        router.get("message", use: self.index)
        router.post("message", use: self.create)
        router.delete("message", Message.parameter, use: self.delete)
    }
}

