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
    
    private var viewContext: NSManagedObjectContext
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
    
    init(repository: JsonPlaceholderWebRepository, dbRepository: JsonPlaceholderDBRepository, viewContext: NSManagedObjectContext) {
        self.repository = repository
        self.dbRepository = dbRepository
        self.viewContext = viewContext
        setupPosts()
        fetchData()
    }
    
    func fetchData() {
        if usingLocalData {
            Task {
                await fetchPostCD()
            }
        } else {
            getPosts()
        }
    }
    
    func addPost(userId: Int, title: String, body: String) {
        repository.createPost(userId: userId, title: title, body: body)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print("\($0.title), \($0.body)") }) // TODO: something better than just print
            .store(in: &cancellable)
    }
    
    func saveData() {
        removeLocalData()
        webPosts?.forEach({ post in
            let postCD = PostCD(context: viewContext)
            postCD.id = Int32(post.id)
            postCD.userId = Int32(post.userId)
            postCD.title = post.title
            postCD.body = post.body
        })
        let result = try? viewContext.save()
        Task {
            await fetchPostCD()
        }
        print(result)
    }
    
    func removeLocalData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PostCD")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let result = try? viewContext.execute(deleteRequest)
        Task {
            await fetchPostCD()
        }
        print(result)
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
                    self?.webPosts = $0
                })
            .store(in: &cancellable)
        
    }
    
    private func fetchPostCD() async { // Move somewhere else
        let fetchRequest: NSFetchRequest<PostCD> = PostCD.fetchRequest()

        try? await viewContext.perform { [weak self] in
            let result = try fetchRequest.execute()

            let posts = result.compactMap { Post(from: $0) }
            self?.localPosts = posts
        }
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
