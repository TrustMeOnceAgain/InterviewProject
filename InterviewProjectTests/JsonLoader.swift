//
//  JsonLoader.swift
//  InterviewProjectTests
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

class JsonLoader {
    static func loadData(_ fileName: String) -> Data {
        let url = Bundle.current.url(forResource: fileName, withExtension: "json")
        return try! Data(contentsOf: url!)
    }
}

private extension Bundle {
    static var current: Bundle {
        class __ { }
        return Bundle(for: __.self)
    }
}
