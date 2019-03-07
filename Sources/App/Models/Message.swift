//
//  Message.swift
//  App
//
//  Created by Bob Quenneville on 2019-01-09.
//

import FluentSQLite
import Vapor

final class Message: SQLiteModel {

    var id: Int?

    var message: String
    var creatorOid: String
    var new: Bool?

    init(id: Int? = nil, message: String, creatorOid: String) {
        self.id = id
        self.message = message
        self.creatorOid = creatorOid
        self.new = true
    }
}

extension Message {
    var users: Siblings<Message, User, UserMessage> {
        return siblings()
    }
}

extension Message: SQLiteMigration { }

extension Message: Content { }

extension Message: Parameter { }
