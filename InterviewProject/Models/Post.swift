//
//  Post.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct Post: Codable {
    let id, userId: Int
    let title, body: String
}
