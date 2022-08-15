//
//  JsonPlaceholderDBRepositoryTests.swift
//  InterviewProjectTests
//
//  Created by Filip Cybuch on 15/08/2022.
//

import XCTest
import Combine
import CoreData
@testable import InterviewProject

class JsonPlaceholderDBRepositoryTests: XCTestCase {
    
    private let expectationTimeout: Double = 2
    private var cancellable = Set<AnyCancellable>()
    private let persistanceService = PersistenceService(inMemory: true)
    
    // MARK: tests
    
    func testFetchPosts() {
        let persistanceService = createPersistenceService(withData: true)
        let repository = JsonPlaceholderDBRepository(persistenceService: persistanceService)
        
        let expectation = XCTestExpectation(description: "FetchPostsExpectation")
        
        let expectedResult = (0..<10).map{ Post(id: $0, userId: $0 * 10, title: "Title: \($0)", body: "Body for index: \($0)") }
        var resultPosts: [Post]? = nil
        
        repository
            .fetchPosts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { posts in
                    resultPosts = posts
                    expectation.fulfill()
                })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: expectationTimeout)
        XCTAssertEqual(resultPosts?.sorted(), expectedResult)
    }
    
    func testStorePosts() {
        let persistanceService = createPersistenceService(withData: false)
        let repository = JsonPlaceholderDBRepository(persistenceService: persistanceService)
        
        let storeExpectation = XCTestExpectation(description: "StorePostsExpectation")
        let fetchExpectation = XCTestExpectation(description: "FetchPostsExpectation")
        
        let expectedResult = (0..<10).map{ Post(id: $0, userId: $0 * 10, title: "Title: \($0)", body: "Body for index: \($0)") }
        var resultPosts: [Post]? = nil
        
        repository
            .storePosts(expectedResult)
            .sink(
                receiveCompletion: {
                    guard case .finished = $0 else { XCTFail("There should be no error"); return }
                    storeExpectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellable)
        
        wait(for: [storeExpectation], timeout: expectationTimeout)
        
        repository
            .fetchPosts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { posts in
                    resultPosts = posts
                    fetchExpectation.fulfill()
                })
            .store(in: &cancellable)
        
        wait(for: [fetchExpectation], timeout: expectationTimeout)
        XCTAssertEqual(resultPosts?.sorted(), expectedResult)
    }
    
    func testDeletePosts() {
        let persistanceService = createPersistenceService(withData: true)
        let repository = JsonPlaceholderDBRepository(persistenceService: persistanceService)
        
        let deleteExpectation = XCTestExpectation(description: "DeletePostsExpectation")
        let fetchExpectation = XCTestExpectation(description: "FetchPostsExpectation")
        
        let expectedResult: [Post] = []
        var resultPosts: [Post]? = nil
        
        repository
            .deleteAllPosts()
            .sink(
                receiveCompletion: {
                    guard case .finished = $0 else { XCTFail("There should be no error"); return }
                    deleteExpectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellable)
        
        wait(for: [deleteExpectation], timeout: expectationTimeout)
        
        repository
            .fetchPosts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { posts in
                    resultPosts = posts
                    fetchExpectation.fulfill()
                })
            .store(in: &cancellable)
        
        wait(for: [fetchExpectation], timeout: expectationTimeout)
        XCTAssertEqual(resultPosts, expectedResult)
    }
    
    private func addMockedData() {
        let viewContext = persistanceService.container.viewContext
        for index in 0..<10 {
            let newPost = PostCD(context: viewContext)
            newPost.id = Int32(index)
            newPost.userId = Int32(index * 10)
            newPost.title = "Title: \(index)"
            newPost.body = "Body for index: \(index)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteAllData() {
        let semaphore = DispatchSemaphore(value: 0)
        persistanceService
            .deleteAllData(for: .post)
            .sink(receiveCompletion: { _ in semaphore.signal() }, receiveValue: { _ in })
            .store(in: &cancellable)
        semaphore.wait()
    }
    
    private func createPersistenceService(withData: Bool) -> PersistenceService {
        
        let persistanceService = PersistenceService(inMemory: true)
        
        guard withData else { return persistanceService }
        
        let viewContext = persistanceService.container.viewContext
        for index in 0..<10 {
            let newPost = PostCD(context: viewContext)
            newPost.id = Int32(index)
            newPost.userId = Int32(index * 10)
            newPost.title = "Title: \(index)"
            newPost.body = "Body for index: \(index)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return persistanceService
    }
}

