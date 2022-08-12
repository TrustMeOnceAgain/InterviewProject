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
}
