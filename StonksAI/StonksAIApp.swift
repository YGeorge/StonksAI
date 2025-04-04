//
//  StonksAIApp.swift
//  StonksAI
//
//  Created by gymydykov on 04.04.2025.
//

import SwiftUI

@main
struct StonksAIApp: App {
    init() {
        // Set global appearance for UINavigationBar
        let appearance = UINavigationBar.appearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.textColor)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textColor)]
        appearance.barTintColor = UIColor(AppTheme.backgroundColor)
        
        // Set list appearance
        UITableView.appearance().backgroundColor = UIColor(AppTheme.backgroundColor)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
