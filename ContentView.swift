import SwiftUI
import FirebaseAuth // Добавьте этот импорт

struct ContentView: View {
    @EnvironmentObject var userService: UserService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if userService.currentUser != nil {
                MainTabView()
            } else {
                authView
            }
        }
    }
    
    private var authView: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: loginUser) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func loginUser() {
        guard validateFields() else { return }
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult: AuthDataResult?, error: Error?) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let uid = authResult?.user.uid else {
                    self.errorMessage = "Ошибка аутентификации"
                    return
                }
                
                self.userService.fetchUser(uid) { success in
                    if !success {
                        self.errorMessage = "Ошибка загрузки данных пользователя"
                        try? Auth.auth().signOut()
                    }
                }
            }
        }
    }
    
    private func validateFields() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Пожалуйста, заполните все поля"
            return false
        }
        guard email.contains("@") else {
            errorMessage = "Введите корректный email"
            return false
        }
        return true
    }
}
