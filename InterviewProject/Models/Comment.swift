//
//  Comment.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct Comment: Decodable {
    let id, postId: Int
    let name, email, body: String
    
    init(id: Int, postId: Int, name: String, email: String, body: String) {
        self.id = id
        self.postId = postId
        self.name = name
        self.email = email
        self.body = body
    }
}

extension Comment: Comparable {
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        guard lhs.postId == rhs.postId else { return lhs.postId < rhs.postId }
        guard lhs.id == rhs.id else { return lhs.id < rhs.id }
        guard lhs.name == rhs.name else { return lhs.name < rhs.name }
        guard lhs.body == rhs.body else { return lhs.body < rhs.body }
        return lhs.email < rhs.email
    }
}
