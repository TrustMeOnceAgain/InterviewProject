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
}
