//
//  PostListViewModel.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Combine
import Foundation

class PostListViewModel: ObservableObject {
    
    @Published var dataStatus: ViewDataStatus<[Post]> = .notLoaded
    
    @Published private var posts: [Post]?
    private let repository: JsonPlaceholderRepository
    private var cancellable: Set<AnyCancellable> = []
    
    init(repository: JsonPlaceholderRepository) {
        self.repository = repository
    }
    
    func fetchData() {
        getPosts()
    }
    
    func addPost(userId: Int, title: String, body: String) {
        repository.createPost(userId: userId, title: title, body: body)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print("\($0.title), \($0.body)") })
            .store(in: &cancellable)
    }
    
    private func getPosts() {
        dataStatus = .loading
        repository.getPosts()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    guard case .failure(let error) = $0 else { return }
                    self?.dataStatus = .error(error)
                },
                  receiveValue: { [weak self] in
                      self?.posts = $0
                      self?.dataStatus = .loaded(data: $0)
            })
            .store(in: &cancellable)
    }
}
