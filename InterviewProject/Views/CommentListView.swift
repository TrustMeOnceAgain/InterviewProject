//
//  CommentListView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI

struct CommentListView: View {
    @ObservedObject var viewModel: CommentListViewModel
    
    init(postId: Int, repository: JsonPlaceholderWebRepository) {
        self.viewModel = CommentListViewModel(postId: postId, repository: repository)
    }
    
    var body: some View {
        contentView
            .navigationTitle("Comments")
    }
}

extension CommentListView {
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.dataStatus {
        case .loaded(data: let comments):
            List(comments, id: \.id) { model in
                createCellView(from: model)
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
    
    private func createCellView(from model: Comment) -> CellView {
        CellView(viewModel: CellViewModel(title: model.body, leftText: String(model.id)))
    }
}

struct CommentListView_Previews: PreviewProvider {
    static var previews: some View {
        CommentListView(postId: 1, repository: JsonPlaceholderWebRepository(networkService: MockedNetworkService(mockedRequests: [])))
    }
}
