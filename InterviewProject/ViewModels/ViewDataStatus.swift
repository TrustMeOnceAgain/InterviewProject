//
//  ViewDataStatus.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

enum ViewDataStatus<T> {
    case notLoaded, loading, loaded(data: T), error(_ error: RequestError)
}
