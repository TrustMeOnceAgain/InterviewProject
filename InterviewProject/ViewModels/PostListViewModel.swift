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
    @Published var addedPost: Post?
    @Published var sortedAscending: Bool = true
    
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
    private let webRepository: JsonPlaceholderWebRepository
    private let dbRepository: JsonPlaceholderDBRepository
    private var cancellable: Set<AnyCancellable> = []
    
    init(webRepository: JsonPlaceholderWebRepository, dbRepository: JsonPlaceholderDBRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        setupPosts()
    }
    
    func fetchData() {
        getPosts()
    }
    
    func addPost(userId: Int, title: String, body: String) {
        webRepository
            .createPost(userId: userId, title: title, body: body)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { print("\(#function): \($0)") },
                receiveValue: { [weak self] in
//                    self?.addedPost = $0
                    // Workaround for Post request always returning the same data
                    var id = $0.id
                    while self?.webPosts?.contains(where: { $0.id == id }) == true {
                        id += 1
                    }
                    let post = Post(id: id, userId: $0.userId, title: $0.title, body: $0.body)
                    self?.webPosts?.append(post)
                })
            .store(in: &cancellable)
    }
    
    func saveToLocalPosts() {
        guard !usingLocalData, let webPosts = webPosts else { return }
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
    
    func deleteLocalPosts() {
        guard usingLocalData else { return }
        dbRepository
            .deleteAllPosts()
            .sink(
                receiveCompletion: { [weak self] in
                    print("\(#function): \($0)")
                    guard case .finished = $0 else { return }
                    self?.localPosts = []
                },
                receiveValue: { _ in })
            .store(in: &cancellable)
    }
    
    func deleteWebPost(id: Int) {
        guard !usingLocalData else { return }
        webRepository
            .deletePost(id: id)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    print("\(#function): \($0)")
                    guard case .finished = $0 else { return }
                    self?.addedPost = nil
                },
                receiveValue: { })
            .store(in: &cancellable)
    }
    
    private func getPosts() {
        dataStatus = .loading
        
        let publisher = usingLocalData ? dbRepository.fetchPosts() : webRepository.getPosts()
        publisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    print("\(#function): \($0)")
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
            .CombineLatest4($webPosts, $localPosts, $usingLocalData, $sortedAscending)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] webPosts, localPosts, usingLocalData, sortedAscending in
                self?.posts = (usingLocalData ? localPosts : webPosts)?.sorted(by: sortedAscending ? (<) : (>) )
            })
            .store(in: &cancellable)
    }
}
