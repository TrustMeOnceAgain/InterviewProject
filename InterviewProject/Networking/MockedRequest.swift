//
//  MockedRequest.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

struct MockedRequest {
    let request: Request
    let response: Result<Data, RequestError>
}

extension MockedRequest: Equatable {
    static func == (lhs: MockedRequest, rhs: MockedRequest) -> Bool {
        return lhs.request.urlRequest == rhs.request.urlRequest && lhs.response == rhs.response
    }
}

extension MockedRequest: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(request.urlRequest)
        hasher.combine(response)
    }
}
