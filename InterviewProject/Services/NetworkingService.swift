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
    func sendRequest(_ request: Request) -> AnyPublisher<Void, RequestError>
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
            .tryMap { [weak self] (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse else { throw RequestError.other(message: "Invalid response format") }
                try self?.handleStatusCode(httpResponse.statusCode)
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                guard let requestError = error as? RequestError else { return .parsingFailure }
                return requestError
            })
            .eraseToAnyPublisher()
    }
    
    func sendRequest(_ request: Request) -> AnyPublisher<Void, RequestError> {
        guard let urlRequest = request.urlRequest else { return Result.Publisher(.failure(RequestError.badURL)).eraseToAnyPublisher() }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse else { throw RequestError.other(message: "Invalid response format") }
                try self?.handleStatusCode(httpResponse.statusCode)
            }
            .mapError({ error in
                guard let requestError = error as? RequestError else { return .other(message: error.localizedDescription) }
                return requestError
            })
            .eraseToAnyPublisher()
    }
    
    private func handleStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 400 ..< 500:
            throw RequestError.badRequest
        case 500 ..< 600 :
            throw RequestError.serverError
        default: break
        }
    }
}

class MockedNetworkService: NetworkingService {
    
    var mockedRequests: [MockedRequest]
    
    init(mockedRequests: [MockedRequest] = []) { // Add mocked data
        self.mockedRequests = mockedRequests
    }
    
    func sendRequest<T: Decodable>(_ request: Request) -> AnyPublisher<T, RequestError> {
        guard let mockedRequest = mockedRequests.last(where: { $0.request.urlRequest == request.urlRequest }) else { return Result.Publisher(.failure(RequestError.badRequest)).eraseToAnyPublisher() }
        
        switch mockedRequest.response {
        case .success(let data):
            guard let data = data else { return Result.Publisher(.failure(RequestError.other(message: "No data!"))).eraseToAnyPublisher() }
            return Result<JSONDecoder.Input, RequestError>.Publisher(.success(data))
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError({ error in
                    guard let requestError = error as? RequestError else { return RequestError.parsingFailure }
                    return requestError
                })
                .eraseToAnyPublisher()
        case .failure(let error):
            return Result.Publisher(.failure(error))
                .eraseToAnyPublisher()
        }
    }
    
    func sendRequest(_ request: Request) -> AnyPublisher<Void, RequestError> {
        guard let mockedRequest = mockedRequests.last(where: { $0.request.urlRequest == request.urlRequest }) else { return Result.Publisher(.failure(RequestError.badRequest)).eraseToAnyPublisher() }
        
        switch mockedRequest.response {
        case .success(_):
            return Result.Publisher(.success(()))
                .eraseToAnyPublisher()
        case .failure(let error):
            return Result.Publisher(.failure(error))
                .eraseToAnyPublisher()
        }
    }
}
