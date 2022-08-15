//
//  CommentListViewModel.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Combine
import Foundation

class CommentListViewModel: ObservableObject {
    
    @Published private(set) var dataStatus: ViewDataStatus<[Comment]> = .notLoaded
    @Published var sortedAscending: Bool = true  {
        didSet {
            comments = comments?.sorted(by: sortedAscending ? (<) : (>))
        }
    }
    
    @Published private var comments: [Comment]? {
        didSet {
            if let comments = comments {
                dataStatus = .loaded(data: comments)
            } else {
                dataStatus = .notLoaded
            }
        }
    }
    private let postId: Int
    private let repository: JsonPlaceholderWebRepository
    private var cancellable: Set<AnyCancellable> = []
    
    init(postId: Int, repository: JsonPlaceholderWebRepository) {
        self.repository = repository
        self.postId = postId
    }
    
    func fetchData() {
        getComments()
    }
    
    func deleteComment(index: Int) {
        guard let comments = comments, let commentId = comments[safe: index]?.id else { return }
        repository
            .deleteComment(id: commentId)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    print("\(#function): \($0)")
                    guard case .finished = $0 else { return }
                    self?.comments?.remove(at: index) // Simulating removal of the comment from the server
                },
                receiveValue: { })
            .store(in: &cancellable)
    }
    
    private func getComments() {
        dataStatus = .loading
        repository.getComments(for: postId)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    print("\(#function): \($0)")
                    guard case .failure(let error) = $0 else { return }
                    self?.dataStatus = .error(error)
                },
                receiveValue: { [weak self] in
                    self?.comments = $0
                })
            .store(in: &cancellable)
    }
}
