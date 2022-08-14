//
//  DeletePostRequest.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

struct DeletePostRequest: Request {
    
    let id: Int
    
    var httpMethod: HTTPMethod { .DELETE }
    var host: Host { .jsonPlaceholder }
    var path: String { "/posts/\(id)" }
    var parameters: Parameters? { nil }
}
