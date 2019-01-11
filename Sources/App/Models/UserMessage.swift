//
//  UserMessage.swift
//  App
//
//  Created by Bob Quenneville on 2019-01-09.
//

import FluentSQLite
import Vapor

final class UserMessage: SQLitePivot {

    typealias Left = User
    typealias Right = Message

    static var leftIDKey:  LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.messageId

    var id: Int?

    var userId: Int
    var messageId: Int

    init(id: Int? = nil, userId: Int, messageId: Message.ID) {
        self.id = id
        self.userId = userId
        self.messageId = messageId
    }
}

extension UserMessage: SQLiteMigration { }
