//
//  User.swift
//  App
//
//  Created by Bob Quenneville on 2019-01-09.
//

import FluentSQLite
import Vapor

final class User: SQLiteModel {

    var id: Int?

    var name: String

    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension User {
    var messages: Siblings<User, Message, UserMessage> {
        return siblings()
    }
}

extension User: SQLiteMigration { }

extension User: Content { }

extension User: Parameter { }
