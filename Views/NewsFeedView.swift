//
//  NewsFeedView.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//
import SwiftUI

struct NewsFeedView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @EnvironmentObject private var userService: UserService
    @State private var newPostText = ""
    @State private var showingNewPost = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.posts) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(post.authorName)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(post.date, style: .relative)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(post.text)
                            .padding(.bottom, 4)
                    }
                    .padding(.vertical, 8)
                    .swipeActions {
                        if post.authorId == userService.currentUser?.id || userService.isCurrentUserAdmin {
                            Button(role: .destructive) {
                                viewModel.deletePost(post)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новости")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewPost = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                VStack(spacing: 20) {
                    TextEditor(text: $newPostText)
                        .frame(minHeight: 100)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    
                    Button("Опубликовать") {
                        viewModel.createPost(text: newPostText)
                        newPostText = ""
                        showingNewPost = false
                    }
                    .disabled(newPostText.isEmpty)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchPosts()
            }
        }
    }
}
