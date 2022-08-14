//
//  DeleteComment.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

struct DeleteCommentRequest: Request {
    
    let id: Int
    
    var httpMethod: HTTPMethod { .DELETE }
    var host: Host { .jsonPlaceholder }
    var path: String { "/comments/\(id)" }
    var parameters: Parameters? { nil }
}
