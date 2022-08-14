//
//  PostListViewModel.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI
import Combine
import Foundation
import CoreData

class PostListViewModel: ObservableObject {
    
    @Published var dataStatus: ViewDataStatus<[Post]> = .notLoaded
    @Published var usingLocalData: Bool = true
    
    @Published private var posts: [Post]? {
        didSet {
            if let posts = posts {
                dataStatus = .loaded(data: posts)
            } else {
                dataStatus = .notLoaded
            }
        }
    }
    @Published private var localPosts: [Post]?
    @Published private var webPosts: [Post]?
    private let repository: JsonPlaceholderWebRepository
    private let dbRepository: JsonPlaceholderDBRepository
    private var cancellable: Set<AnyCancellable> = []
    
    init(repository: JsonPlaceholderWebRepository, dbRepository: JsonPlaceholderDBRepository) {
        self.repository = repository
        self.dbRepository = dbRepository
        setupPosts()
    }
    
    func fetchData() {
        getPosts()
    }
    
    func addPost(userId: Int, title: String, body: String) {
        repository.createPost(userId: userId, title: title, body: body)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print("\($0.title), \($0.body)") }) // TODO: something better than just print
            .store(in: &cancellable)
    }
    
    func savePosts() {
        guard !usingLocalData, let webPosts = self.webPosts else { return }
        dbRepository.storePosts(webPosts)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.localPosts = webPosts
                    case .failure(let error):
                        print(error)
                    }
                },
                receiveValue: { _ in })
            .store(in: &cancellable)

    }
    
    func deletePosts() {
        guard usingLocalData else { return }
        dbRepository
            .deleteAllPosts()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.localPosts = []
                    case .failure(let error):
                        print(error)
                    }
                },
                receiveValue: { _ in })
            .store(in: &cancellable)
    }
    
    private func getPosts() {
        dataStatus = .loading
        
        let publisher = usingLocalData ? dbRepository.fetchPosts() : repository.getPosts()
        publisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    print($0)
                    guard case .failure(let error) = $0 else { return }
                    self?.dataStatus = .error(error)
                },
                receiveValue: { [weak self] in
                    if self?.usingLocalData == true {
                        self?.localPosts = $0
                    } else {
                        self?.webPosts = $0
                    }
                })
            .store(in: &cancellable)
        
    }
    
    private func setupPosts() {
        Publishers
            .CombineLatest3($webPosts, $localPosts, $usingLocalData)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] webPosts, localPosts, usingLocalData in
                self?.posts = usingLocalData ? localPosts : webPosts
            })
            .store(in: &cancellable)
    }
}
