//
//  JsonPlaceholderDBRepository.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation
import Combine
import CoreData

class JsonPlaceholderDBRepository {
    
    let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    func fetchPosts() -> AnyPublisher<[Post], RequestError> {
        let fetchRequest = PostCD.fetchRequest()
        return persistenceService
            .fetchData(fetchRequest)
            .map { $0.compactMap { Post(from: $0) } }
            .mapError { error -> RequestError in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
    
    func storePosts(_ posts: [Post]) -> AnyPublisher<Void, RequestError> {
        posts.forEach { post in
            let postCD = PostCD(context: persistenceService.container.viewContext)
            postCD.id = Int32(post.id)
            postCD.userId = Int32(post.userId)
            postCD.title = post.title
            postCD.body = post.body
        }
        
        return persistenceService
            .storeData()
            .mapError { error in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAllPosts() -> AnyPublisher<Void, RequestError> {
        persistenceService
            .deleteAllData(for: .post)
            .mapError { error in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
}
