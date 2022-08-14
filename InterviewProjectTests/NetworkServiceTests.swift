//
//  NetworkServiceTests.swift
//  InterviewProjectTests
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Combine
import XCTest
@testable import InterviewProject

class NetworkServiceTests: XCTestCase {
    
    private let expectationTimeout: Double = 2
    private var cancellable = Set<AnyCancellable>()
    
    func testErrors() {
        let request = GetPostsRequest()
        let secondRequest = DeletePostRequest(id: 1)
        let thirdRequest = DeleteCommentRequest(id: 3)
        let fourthRequest = GetCommentsRequest(postId: 1)
        let fifthRequest = CreatePostRequest(userId: 1, title: "Dunno", body: "It does not matter anyway")
        
        let mockedRequests: [MockedRequest] = [MockedRequest(request: request, response: .failure(.badURL)),
                                               MockedRequest(request: secondRequest, response: .failure(.parsingFailure)),
                                               MockedRequest(request: thirdRequest, response: .failure(.badRequest)),
                                               MockedRequest(request: fourthRequest, response: .failure(.serverError)),
                                               MockedRequest(request: fifthRequest, response: .failure(.other(message: "Some message")))]
        
        let networkService = MockedNetworkService(mockedRequests: mockedRequests)
        
        let requests: [Request] = [request, secondRequest, thirdRequest, fourthRequest, fifthRequest]
        let expectation = XCTestExpectation(description: "GetPostsExpectation")
        expectation.expectedFulfillmentCount = requests.count
        
        let expectedResult: Set<RequestError> = Set(mockedRequests.compactMap { $0.error })
        var result: Set<RequestError> = []
        
        requests.forEach({ request in
            networkService
                .sendRequest(request)
                .sink(
                    receiveCompletion: {
                        guard case .failure(let error) = $0 else { XCTFail(); return }
                        result.insert(error)
                        expectation.fulfill()
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellable)
        })
        wait(for: [expectation], timeout: expectationTimeout)
        XCTAssertEqual(result, expectedResult)
    }
}
