//
//  JsonPlaceholderWebRepository.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import Combine

class JsonPlaceholderWebRepository: ObservableObject {
    
    let networkService: NetworkingService
    
    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
    
    func getComments(for postId: Int) -> AnyPublisher<[Comment], RequestError> {
        let request = GetCommentsRequest(postId: postId)
        return networkService
            .sendRequest(request)
            .eraseToAnyPublisher()
    }
    
    func getPosts() -> AnyPublisher<[Post], RequestError> {
        let request = GetPostsRequest()
        return networkService
            .sendRequest(request)
            .eraseToAnyPublisher()
    }
    
    func createPost(userId: Int, title: String, body: String) -> AnyPublisher<Post, RequestError>  {
        let request = CreatePostRequest(userId: userId, title: title, body: body)
        return networkService
            .sendRequest(request)
            .eraseToAnyPublisher()
    }
}
