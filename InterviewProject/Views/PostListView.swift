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
    private var webRepository: JsonPlaceholderWebRepository
    
    init(webRepository: JsonPlaceholderWebRepository, dbRepository: JsonPlaceholderDBRepository) {
        self.viewModel = PostListViewModel(webRepository: webRepository, dbRepository: dbRepository)
        self.webRepository = webRepository
    }
    
    var body: some View {
        contentView
            .navigationTitle("Posts")
            .toolbar {
                toolbarView
            }
            .alert(item: $viewModel.addedPost) { post in
                Alert(title: Text("Added new post"),
                      message: Text("Id: \(post.id)\nTitle: \(post.title)\nBody: \(post.body)"),
                      dismissButton: .default(Text("OK"),
                                              action: { viewModel.addedPost = nil }))
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
                List(posts, id: \.id) { model in
                    if viewModel.usingLocalData {
                        createCellView(from: model)
                    } else {
                        NavigationLink(destination: { CommentListView(postId: model.id, repository: webRepository) }) {
                            createCellView(from: model)
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
    
    @ToolbarContentBuilder
    private var toolbarView: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { viewModel.fetchData() }, label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
            })
            if !viewModel.usingLocalData {
                Button(action: { viewModel.addPost(userId: 1, title: "Title", body: "Body") }, label: {
                    Image(systemName: "plus.circle.fill")
                })
            }
        }
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(action: { viewModel.usingLocalData.toggle() }, label: {
                Image(systemName: viewModel.usingLocalData ? "cloud" : "cloud.fill")
                
            })
            if !viewModel.usingLocalData {
                Button(action: { viewModel.saveToLocalPosts() }, label: {
                    Text("Save")
                    Image(systemName: "externaldrive.fill.badge.plus")
                })
            } else {
                Button(action: { viewModel.deleteLocalPosts() }, label: {
                    Text("Delete")
                    Image(systemName: "externaldrive.fill.badge.xmark")
                })
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: { viewModel.sortedAscending.toggle() }, label: {
                Text("Sort")
                Image(systemName: viewModel.sortedAscending ? "arrow.up.arrow.down.square.fill" : "arrow.up.arrow.down.square")
            })
        }
    }
    
    private func createCellView(from model: Post) -> CellView {
        CellView(viewModel: CellViewModel(title: model.title, leftText: String(model.id)))
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { colorScheme in
                NavigationView {
                PostListView(webRepository: JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: [])), dbRepository: JsonPlaceholderDBRepository(persistenceService: PersistenceService.preview))
                    .preferredColorScheme(colorScheme)
                }
            }
        }
        .previewLayout(.device)
    }
}
