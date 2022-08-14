//
//  PostListView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI
import CoreData

struct PostListView: View {
    
    @ObservedObject var viewModel: PostListViewModel
    private var repository: JsonPlaceholderWebRepository
    
    init(repository: JsonPlaceholderWebRepository, dbRepository: JsonPlaceholderDBRepository) {
        self.viewModel = PostListViewModel(repository: repository, dbRepository: dbRepository)
        self.repository = repository
    }
    
    var body: some View {
        contentView
            .navigationTitle("Posts")
//            .toolbar(content: {
//                Button("Add post") {
//                    viewModel.addPost(userId: 1, title: "Some title", body: "So body so new!")
//                }
//            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.fetchData()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                        Toggle("Local data", isOn: $viewModel.usingLocalData)
                    if !viewModel.usingLocalData {
                        Button("Save") {
                            viewModel.savePosts()
                        }
                    } else {
                        Button("Delete all") {
                            viewModel.deletePosts()
                        }
                    }
                }
            }
    }
}

extension PostListView {
    @ViewBuilder
    private var contentView: some View {
        
        switch viewModel.dataStatus {
        case .loaded(data: let posts):
            if posts.isEmpty {
                Text("There are no posts to show")
            } else {
                List {
                    ForEach(posts, id: \.id) { model in
                        NavigationLink(destination: { CommentListView(postId: model.id, repository: repository) }) {
                            Text(model.title)
                        }
                    }
                }
            }
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
        case .notLoaded:
            VStack {
                Text("Not loaded yet")
            }
            .onAppear {
                viewModel.fetchData()
            }
        }
    }
}

//struct PostListView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ForEach(ColorScheme.allCases, id: \.hashValue) { colorScheme in
////                PostListView(repository: JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: [])), viewContext: <#NSManagedObjectContext#>)
//            }
//        }
//        .previewLayout(.device)
//    }
//}
