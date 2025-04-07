//
//  MainTabView.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var isShowingAssistant = false
    @EnvironmentObject private var userService: UserService
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                TasksView()
                    .tabItem { Label("Задачи", systemImage: "checklist") }
                
                NewsFeedView()
                    .tabItem { Label("Новости", systemImage: "newspaper") }
                
                CalendarView()
                    .tabItem { Label("Календарь", systemImage: "calendar") }
                
                ProfileView()
                    .tabItem { Label("Профиль", systemImage: "person") }
            }
            
            // Плавающая кнопка помощника
            Button {
                isShowingAssistant = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
                    .padding()
            }
            .sheet(isPresented: $isShowingAssistant) {
                AssistantView()
            }
            .opacity(userService.currentUser == nil ? 0 : 1)
        }
    }
}
