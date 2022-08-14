//
//  Post.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct Post: Decodable, Identifiable {
    let id, userId: Int
    let title, body: String
    
    init(id: Int, userId: Int, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
    
    init?(from postCD: PostCD) {
        guard let title = postCD.title, let body = postCD.body else { return nil }
        self.id = Int(postCD.id)
        self.userId = Int(postCD.userId)
        self.title = title
        self.body = body
    }
}

extension Post: Comparable {
    static func < (lhs: Post, rhs: Post) -> Bool {
        guard lhs.id == rhs.id else { return lhs.id < rhs.id }
        guard lhs.title == rhs.title else { return lhs.title < rhs.title }
        guard lhs.body == rhs.body else { return lhs.body < rhs.body }
        return lhs.userId < rhs.userId
    }
}
