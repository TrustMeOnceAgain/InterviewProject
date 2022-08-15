//
//  MainView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 15/08/2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        List {
            NavigationLink("Go to posts") {
                PostListView(webRepository: DIManager.shared.jsonPlaceholderWebRepository,
                             dbRepository: DIManager.shared.jsonPlaceholderDBRepository)
            }
        }
        .navigationTitle("Main view")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView()
        }
    }
}
