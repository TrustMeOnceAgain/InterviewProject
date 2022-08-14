//
//  JsonPlaceholderWebRepositoryTests.swift
//  InterviewProjectTests
//
//  Created by Filip Cybuch on 14/08/2022.
//

import XCTest
import Combine
@testable import InterviewProject

class JsonPlaceholderWebRepositoryTests: XCTestCase {
    
    private let expectationTimeout: Double = 2
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: tests
    
    func testGetPosts() {
        
        let mockedRequests = [MockedRequest(request: GetPostsRequest(), response: .success(JsonLoader.loadData("GetPostsRequestMock")))]
        let repository = JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: mockedRequests))
        let expectedResult: [Post] = (1...5).map { index in Post(id: index, userId: index, title: "Title\(index)", body: "Body\(index)") }
        
        let expectation = XCTestExpectation(description: "GetPostsExpectation")
        var resultPosts: [Post]? = nil
        
        repository
            .getPosts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { posts in
                    resultPosts = posts
                    
                    expectation.fulfill()
                })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: expectationTimeout)
        XCTAssertEqual(resultPosts, expectedResult)
    }
    
    func testGetPosts_Error() {
        
        let mockedRequests = [MockedRequest(request: GetPostsRequest(), response: .failure(.serverError))]
        let repository = JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: mockedRequests))
        let expectedResult: RequestError = .serverError
        
        let expectation = XCTestExpectation(description: "GetPostsExpectation")
        var resultPosts: RequestError? = nil
        
        repository
            .getPosts()
            .sink(
                receiveCompletion: {
                    guard case .failure(let error) = $0 else { XCTFail(); return }
                    resultPosts = error
                    expectation.fulfill()
                },
                receiveValue: { _ in}
            )
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: expectationTimeout)
        XCTAssertEqual(resultPosts, expectedResult)
    }
    
    func testGetComments() {
        
        let mockedRequests = [
            MockedRequest(request: GetCommentsRequest(postId: 1), response: .success(JsonLoader.loadData("GetCommentsRequestMock_PostId1"))),
            MockedRequest(request: GetCommentsRequest(postId: 2), response: .success(JsonLoader.loadData("GetCommentsRequestMock_PostId2")))
        ]
        
        let repository = JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: mockedRequests))
        
        let expectedResultForPost1: [Comment] = (1...3).map { index in Comment(id: index, postId: 1, name: "Name\(index)", email: "name\(index)@gmail.com", body: "Body\(index)") }
        let expectedResultForPost2: [Comment] = [Comment(id: 4, postId: 2, name: "Name4", email: "name4@gmail.com", body: "Body4")]
        
        let expectation = XCTestExpectation(description: "GetCommentsExpectation")
        
        var resultCommentsForPost1: [Comment]? = nil
        var resultCommentsForPost2: [Comment]? = nil
        
        let firstRequest = repository.getComments(for: 1)
        let secondRequest = repository.getComments(for: 2)
        
        Publishers
            .Zip(firstRequest, secondRequest)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { comments1, comments2 in
                resultCommentsForPost1 = comments1
                resultCommentsForPost2 = comments2
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: expectationTimeout)
        XCTAssertEqual(resultCommentsForPost1, expectedResultForPost1)
        XCTAssertEqual(resultCommentsForPost2, expectedResultForPost2)
    }
}
