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
    var oid: Int

    init(id: Int? = nil, name: String, oid: Int) {
        self.id = id
        self.name = name
        self.oid = oid
    }

    class func findUser(using request: Request, with oid: Int) -> Future<User> {
        return request.withPooledConnection(to: .sqlite) { connection -> Future<User> in
                   return connection.raw("""
                                          SELECT * FROM User WHERE OID == \(oid);
                                          """).first(decoding: User.self).unwrap(or: Abort(.notFound))
        }
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
