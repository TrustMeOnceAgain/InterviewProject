//
//  Post.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct Post: Decodable {
    let id, userId: Int
    let title, body: String
    
    init?(from postCD: PostCD) {
        guard let title = postCD.title, let body = postCD.body else { return nil }
        self.id = Int(postCD.id)
        self.userId = Int(postCD.userId)
        self.title = title
        self.body = body
    }
}
