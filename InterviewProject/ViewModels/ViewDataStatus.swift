//
//  ViewDataStatus.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

enum ViewDataStatus<T> {
    case notLoaded, loading, loaded(data: T), error(_ error: RequestError)
    
    var data: T? {
        guard case .loaded(let data) = self else { return nil }
        return data
    }
    
    var error: RequestError? {
        guard case .error(let error) = self else { return nil }
        return error
    }
}
