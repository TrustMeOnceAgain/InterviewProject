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
    
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    func fetchPosts() -> AnyPublisher<[Post], RequestError> {
        persistenceController
            .fetchData()
            .tryMap({ (nsManagedObjects: [NSManagedObject]) -> [Post] in
                guard let postsCD = nsManagedObjects as? [PostCD] else { throw RequestError.parsingFailure }
                let posts = postsCD.compactMap { Post(from: $0) }
                return posts
            })
            .mapError { error in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
    
    func storePosts(_ posts: [Post]) -> AnyPublisher<Void, RequestError> {
        posts.forEach { post in
            let postCD = PostCD(context: persistenceController.container.viewContext)
            postCD.id = Int32(post.id)
            postCD.userId = Int32(post.userId)
            postCD.title = post.title
            postCD.body = post.body
        }
        
        return persistenceController
            .storeData()
            .mapError { error in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAllPosts() -> AnyPublisher<Void, RequestError> {
        persistenceController
            .deleteAllData(for: .post)
            .mapError { error in
                guard let requestError = error as? RequestError else { return RequestError.localError }
                return requestError
            }
            .eraseToAnyPublisher()
    }
}
