//
//  ProfileView.swift
//  NikitaCRM
//
//  Created by Никита Черников on 04.04.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userService: UserService
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = userService.currentUser {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(user.name)
                        .font(.title)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Роль: \(user.role.displayName)")
                        .font(.headline)
                }
                .padding()
                
                if userService.isCurrentUserAdmin {
                    NavigationLink {
                        AdminView()
                    } label: {
                        Text("Админ панель")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Выйти", role: .destructive) {
                    showingLogoutAlert = true
                }
                .buttonStyle(.bordered)
                .alert("Выход", isPresented: $showingLogoutAlert) {
                    Button("Отмена", role: .cancel) {}
                    Button("Выйти", role: .destructive) {
                        userService.logout()
                    }
                } message: {
                    Text("Вы уверены, что хотите выйти из аккаунта?")
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("Профиль")
    }
}
