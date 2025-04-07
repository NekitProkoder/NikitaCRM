//
//  NewsFeedViewModel.swift
//  NikitaCRM
//
//  Created by Никита Черников on 04.04.2025.
import FirebaseDatabase
import FirebaseAuth
import Combine

class NewsFeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Database.database().reference()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPosts() {
        isLoading = true
        db.child("posts")
            .queryOrdered(byChild: "date")
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                self?.handlePostsSnapshot(snapshot)
            }
    }
    
    private func handlePostsSnapshot(_ snapshot: DataSnapshot) {
        defer { isLoading = false }
        
        guard let value = snapshot.value as? [String: Any] else {
            return posts = []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            posts = try value.compactMap { id, value -> Post? in
                guard let dict = value as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: dict),
                      let authorId = dict["authorId"] as? String else {
                    return nil
                }
                var post = try decoder.decode(Post.self, from: data)
                post.id = id
                post.authorId = authorId
                return post
            }.sorted { $0.date > $1.date }
        } catch {
            errorMessage = "Ошибка загрузки постов: \(error.localizedDescription)"
        }
    }
    
    func createPost(text: String) {
        guard let userId = Auth.auth().currentUser?.uid,
              let userName = Auth.auth().currentUser?.email?.components(separatedBy: "@").first else {
            errorMessage = "Пользователь не аутентифицирован"
            return
        }
        
        let postData: [String: Any] = [
            "authorName": userName,
            "text": text,
            "date": Date().timeIntervalSince1970,
            "authorId": userId
        ]
        
        db.child("posts").childByAutoId().setValue(postData) { [weak self] error, _ in
            if let error = error {
                self?.errorMessage = "Ошибка создания поста: \(error.localizedDescription)"
            } else {
                self?.fetchPosts()
            }
        }
    }
    
    func deletePost(_ post: Post) {
        guard let postId = post.id else { return }
        db.child("posts").child(postId).removeValue()
    }
}
