//
//  RequestError.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

enum RequestError: Error {
    case badURL, parsingFailure, badRequest, serverError, localError, other(message: String)
    
    var localizedDescription: String {
        switch self {
        case .badURL: return "Bad URL"
        case .parsingFailure: return "Parsing failed"
        case .badRequest: return "Bad request"
        case .serverError: return "Server error"
        case .localError: return "Local error"
        case .other(let message): return "Other error: \(message)"
        }
    }
}

extension RequestError: Hashable {}
