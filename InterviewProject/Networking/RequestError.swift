//
//  RequestError.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

enum RequestError: Error { // TODO: extend
    case badURL, parsingFailure, badRequest, serverError
}
