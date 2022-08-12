//
//  NetworkingService.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Foundation
import Combine

protocol NetworkController {
    func sendRequest<T: Decodable>(_ request: Request) async throws -> T
    func asyncRequestToCombine<T>(_ asyncRequest: @escaping () async throws -> T, queue: DispatchQueue) -> AnyPublisher<T, RequestError>
}

extension NetworkController {
    func asyncRequestToCombine<T>(_ asyncRequest: @escaping () async throws -> T, queue: DispatchQueue) -> AnyPublisher<T, RequestError> {
        Future { promise in
            Task {
                do {
                    promise(.success(try await asyncRequest()))
                } catch (let error as RequestError){
                    promise(.failure(error))
                } catch {
                    promise(.failure(.badRequest))
                }
            }
        }
        .receive(on: queue)
        .eraseToAnyPublisher()
    }
}

class RealNetworkController: NetworkController {
    
    private let urlSession: URLSession
    
    init(timeout: TimeInterval = 10.0) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.urlSession = URLSession(configuration: configuration)
    }
    
#warning("TODO: map responseToError")
    func sendRequest<T: Decodable>(_ request: Request) async throws -> T {
        do {
            let (data, _) = try await baseRequest(request)
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
            guard let model = try? jsonDecoder.decode(T.self, from: data) else { throw RequestError.parsingFailure }
            return model
        } catch (let error as RequestError) {
            throw error
        } catch {
            throw RequestError.badRequest
        }
    }
    
    private func baseRequest(_ request: Request) async throws -> (Data, URLResponse) {
        guard let urlRequest = request.urlRequest else { throw RequestError.badURL }
        guard let (data, response) = try? await urlSession.data(for: urlRequest) else { throw RequestError.badRequest }
        return (data, response)
    }
}

class MockedNetworkController: NetworkController {
    
    var mockedRequests: [MockedRequest]
    
    init(mockedRequests: [MockedRequest]) {
        self.mockedRequests = mockedRequests
    }
    
    func sendRequest<T>(_ request: Request) async throws -> T where T : Decodable {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
        
        guard let mockedRequest = mockedRequests.last(where: { $0.request.urlRequest == request.urlRequest }) else { throw RequestError.badRequest }
        
        switch mockedRequest.response {
        case .success(let data):
            guard let model = try? jsonDecoder.decode(T.self, from: data) else { throw RequestError.parsingFailure }
            return model
        case .failure(let error):
            throw error
        }
    }
}
