//
//  Request.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation

protocol Request {
    var path: String { get }
    var host: Host { get }
    var parameters: Parameters? { get }
    var parametersEncoding: ParameteresEncoding { get }
    var httpMethod: HTTPMethod { get }
    var urlRequest: URLRequest? { get }
}

extension Request {
    
    var parametersEncoding: ParameteresEncoding { httpMethod == .GET ? .url : .json }
    
    var urlRequest: URLRequest? {
        
        guard var url = URL(string: host.value + path) else { return nil }
        
        let bodyData: Data?
        let headers: [String: String]?
        
        switch parametersEncoding {
        case .url:
            if let urlWithParameters = url.withParameters(parameters) {
                url = urlWithParameters
            }
            bodyData = nil
            headers = nil
        case .json:
            bodyData = parameters?.encode()
            headers = ["Accept": "application/json", "Content-Type": "application/json"]
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.httpBody = bodyData
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}

typealias Parameters = [String: Any]

private extension Parameters {
    func encode() -> Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }
    
    func encode() -> [URLQueryItem] {
        let queryItems: [URLQueryItem] = self.map { (key, value) in
            URLQueryItem(name: key, value: String(describing: value))
        }.compactMap { $0 }
        
        return queryItems
    }
}

private extension URL {
    func withParameters(_ parameters: Parameters?) -> URL? {
        guard let parameters = parameters else { return self }
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.queryItems = parameters.encode()
        return urlComponents.url
    }
}
