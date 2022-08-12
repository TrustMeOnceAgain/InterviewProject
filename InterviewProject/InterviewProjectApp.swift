//
//  InterviewProjectApp.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI

@main
struct InterviewProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                PostListView(repository: JsonPlaceholderRepository(networkService: RealNetworkService()))
            }
            .navigationViewStyle(.stack)
            
                
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
