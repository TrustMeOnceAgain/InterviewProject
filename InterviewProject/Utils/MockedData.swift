//
//  MockedData.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

struct MockedData {
    static let defaultMockedRequests: [MockedRequest] = [
        MockedRequest(request: GetPostsRequest(), response: .success(JsonLoader.loadData("GetPostsRequestMock"))),
        MockedRequest(request: CreatePostRequest(userId: 1, title: "Title", body: "Body"), response: .success(JsonLoader.loadData("CreatePostRequestMock"))),
        MockedRequest(request: DeletePostRequest(id: 101), response: .success(nil)),
        
        MockedRequest(request: GetCommentsRequest(postId: 1), response: .success(JsonLoader.loadData("GetCommentsRequestMock_PostId1"))),
        MockedRequest(request: GetCommentsRequest(postId: 2), response: .success(JsonLoader.loadData("GetCommentsRequestMock_PostId2"))),
        MockedRequest(request: GetCommentsRequest(postId: 3), response: .success(JsonLoader.loadData("EmptyListMock"))),
        MockedRequest(request: GetCommentsRequest(postId: 4), response: .success(JsonLoader.loadData("EmptyListMock"))),
        MockedRequest(request: GetCommentsRequest(postId: 5), response: .success(JsonLoader.loadData("EmptyListMock"))),
        
        MockedRequest(request: DeleteCommentRequest(id: 1), response: .success(nil)),
        MockedRequest(request: DeleteCommentRequest(id: 2), response: .success(nil)),
        MockedRequest(request: DeleteCommentRequest(id: 3), response: .success(nil)),
        MockedRequest(request: DeleteCommentRequest(id: 4), response: .failure(.parsingFailure))
        
    ]
}
