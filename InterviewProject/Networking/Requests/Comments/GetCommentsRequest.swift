//
//  GetCommentsRequest.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct GetCommentsRequest: Request {
    
    let postId: Int?
    
    var httpMethod: HTTPMethod { .GET }
    var host: Host { .jsonPlaceholder }
    var path: String { "/comments" }
    
    var parameters: Parameters? {
        guard let postId = postId else { return nil }
        return ["postId": postId]
    }
}
