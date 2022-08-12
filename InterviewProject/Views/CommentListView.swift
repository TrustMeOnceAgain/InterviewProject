//
//  CommentListView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI

struct CommentListView: View {
    @ObservedObject var viewModel: CommentListViewModel
    
    var body: some View {
        contentView
            .navigationTitle("Posts")
    }
}

extension CommentListView {
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.dataStatus {
        case .loaded(data: let comments):
            List(comments, id: \.id) { model in
                Text(model.body)
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

struct CommentListView_Previews: PreviewProvider {
    static var previews: some View {
        CommentListView(viewModel: CommentListViewModel(postId: 1, repository: JsonPlaceholderRepository(networkService: MockedNetworkService(mockedRequests: []))))
    }
}
