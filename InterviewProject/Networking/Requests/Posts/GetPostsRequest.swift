//
//  GetPostsRequest.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct GetPostsRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var host: Host { .jsonPlaceholder }
    var path: String { "/posts" }
    var parameters: Parameters? { nil }
}
