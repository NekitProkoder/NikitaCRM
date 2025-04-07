//
//  UserService.swift
//  NikitaCRM
//

import Firebase
import FirebaseAuth
import FirebaseDatabase

final class UserService: ObservableObject {
    @Published private(set) var currentUser: AppUser?
    private let db = Database.database().reference()
    
    static let shared = UserService()
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            if let uid = user?.uid {
                self.fetchUser(uid) { success in
                    if !success {
                        print("Failed to fetch user data")
                        try? Auth.auth().signOut()
                    }
                }
            } else {
                self.currentUser = nil
            }
        }
    }
    
    func fetchUser(_ userId: String, completion: @escaping (Bool) -> Void) {
        db.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let dict = snapshot.value as? [String: Any],
                  let name = dict["name"] as? String,
                  let email = dict["email"] as? String,
                  let roleRaw = dict["role"] as? String,
                  let role = AppUser.UserRole(rawValue: roleRaw) else {
                completion(false)
                return
            }
            
            let user = AppUser(
                id: userId,
                name: name,
                email: email,
                role: role
            )
            
            DispatchQueue.main.async {
                self.currentUser = user
                completion(true)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out:", error.localizedDescription)
        }
    }
}
