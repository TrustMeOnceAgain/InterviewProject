//
//  Host.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

enum Host {
    case jsonPlaceholder
    
    var value: String {
        switch self {
        case .jsonPlaceholder: return "https://jsonplaceholder.typicode.com"
        }
    }
}
