//
//  NikitaCRMApp.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct NikitaCRMApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userService = UserService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userService)
                .onAppear {
                    if let uid = Auth.auth().currentUser?.uid {
                        userService.fetchUser(uid) { _ in } // Добавлен completion handler
                    }
                }
        }
    }
}
