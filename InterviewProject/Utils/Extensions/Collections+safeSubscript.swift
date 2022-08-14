//
//  Collections+safeSubscript.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

// https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
