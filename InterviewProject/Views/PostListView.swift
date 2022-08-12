//
//  PostListView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI

struct PostListView: View {
    
    @ObservedObject var viewModel: PostListViewModel
    private var repository: JsonPlaceholderRepository
    
    init(repository: JsonPlaceholderRepository) {
        self.viewModel = PostListViewModel(repository: repository)
        self.repository = repository
    }
    
    var body: some View {
        contentView
            .navigationTitle("Posts")
    }
}

#warning("Pass environment object networking service")
extension PostListView {
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.dataStatus {
        case .loaded(data: let posts):
            List(posts, id: \.id) { model in
                NavigationLink(destination: { CommentListView(viewModel: CommentListViewModel(postId: model.id, repository: repository)) }) {
                    Text(model.title)
                }
            }
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
        case .notLoaded:
            Text("Not loaded yet")
                .onAppear {
                    viewModel.fetchData()
                }
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { colorScheme in
                PostListView(repository: JsonPlaceholderRepository(networkService: MockedNetworkService(mockedRequests: [])))
            }
        }
        .previewLayout(.device)
    }
}
