//
//  InterviewProjectApp.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import SwiftUI

@main
struct InterviewProjectApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
            }
            .navigationViewStyle(.stack)
        }
    }
}
