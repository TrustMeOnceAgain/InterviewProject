//
//  CommentListViewModel.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Combine
import Foundation

class CommentListViewModel: ObservableObject {
    
    @Published var dataStatus: ViewDataStatus<[Comment]> = .notLoaded
    
    @Published private var comments: [Comment]?
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
    
    private func getComments() {
        dataStatus = .loading
        repository.getComments(for: postId)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    guard case .failure(let error) = $0 else { return }
                    self?.dataStatus = .error(error)
                },
                  receiveValue: { [weak self] in
                      self?.comments = $0
                      self?.dataStatus = .loaded(data: $0)
            })
            .store(in: &cancellable)
    }
}
