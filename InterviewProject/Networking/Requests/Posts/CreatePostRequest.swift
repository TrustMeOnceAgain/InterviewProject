//
//  CreatePostRequest.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct CreatePostRequest: Request {
    
    let userId: Int
    let title, body: String
    
    var httpMethod: HTTPMethod { .POST }
    var host: Host { .jsonPlaceholder }
    var path: String { "/posts" }
    var parameters: Parameters? { ["userId": userId,
                                   "title": title,
                                   "body": body] }
}
