//
//  NetworkingService.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation
import Combine

protocol NetworkingService {
    func sendRequest<T: Decodable>(_ request: Request) -> AnyPublisher<T, RequestError>
}

class RealNetworkService: NetworkingService {
    
    private let urlSession: URLSession
    
    init(timeout: TimeInterval = 10.0) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func sendRequest<T: Decodable>(_ request: Request) -> AnyPublisher<T, RequestError> {
        guard let urlRequest = request.urlRequest else { return Result.Publisher(.failure(RequestError.badURL)).eraseToAnyPublisher() }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw RequestError.badRequest }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                guard let requestError = error as? RequestError else { return .badRequest }
                return requestError
            })
            .eraseToAnyPublisher()
    }
}

class MockedNetworkService: NetworkingService {
    
    var mockedRequests: [MockedRequest]
    
    init(mockedRequests: [MockedRequest]) {
        self.mockedRequests = mockedRequests
    }
    
    func sendRequest<T: Decodable>(_ request: Request) -> AnyPublisher<T, RequestError> {
        guard let mockedRequest = mockedRequests.last(where: { $0.request.urlRequest == request.urlRequest }) else { return Result.Publisher(.failure(RequestError.badRequest)).eraseToAnyPublisher() }
        
        switch mockedRequest.response {
        case .success(let data):
            return Result<JSONDecoder.Input, RequestError>.Publisher(.success(data))
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError({ error in
                    guard let requestError = error as? RequestError else { return RequestError.badRequest }
                    return requestError
                })
                .eraseToAnyPublisher()
        case .failure(let error):
            return Result.Publisher(.failure(error))
                .eraseToAnyPublisher()
        }
    }
}
