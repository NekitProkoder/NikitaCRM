//
//  AdminView.swift
//  NikitaCRM
//

import SwiftUI
import FirebaseAuth

struct AdminView: View {
    @EnvironmentObject var userService: UserService
    @State private var showingAddUser = false
    @State private var searchText = ""
    @State private var errorMessage = ""
    
    var filteredUsers: [AppUser] {
        if searchText.isEmpty {
            return userService.users
        } else {
            return userService.users.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredUsers) { user in
                    UserRowView(user: user)
                        .swipeActions {
                            if user.id != userService.currentUser?.id {
                                Button(role: .destructive) {
                                    deleteUser(user.id)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Управление пользователями")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddUser = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView()
                    .environmentObject(userService)
            }
            .onAppear {
                userService.fetchAllUsers()
            }
            .alert("Ошибка", isPresented: .constant(!errorMessage.isEmpty)) {
                Button("OK") { errorMessage = "" }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func deleteUser(_ userId: String) {
        userService.deleteUser(userId: userId) { error in
            if let error = error {
                errorMessage = "Ошибка удаления пользователя: \(error.localizedDescription)"
                return
            }
            
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    errorMessage = "Ошибка удаления аутентификационных данных: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct UserRowView: View {
    @EnvironmentObject var userService: UserService
    let user: AppUser
    @State private var errorMessage = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Picker("Роль", selection: Binding(
                get: { user.role },
                set: { newValue in updateRole(newValue) }
            )) {
                ForEach(AppUser.UserRole.allCases, id: \.self) { role in
                    Text(role.displayName).tag(role)
                }
            }
            .pickerStyle(.menu)
            .disabled(user.id == userService.currentUser?.id)
        }
        .alert("Ошибка", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateRole(_ newRole: AppUser.UserRole) {
        userService.updateUserRole(userId: user.id, newRole: newRole) { error in
            if let error = error {
                errorMessage = "Ошибка обновления роли: \(error.localizedDescription)"
            }
        }
    }
}

struct AddUserView: View {
    @EnvironmentObject var userService: UserService
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var role: AppUser.UserRole = .employee
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Пароль", text: $password)
                }
                
                Section("Роль") {
                    Picker("Роль", selection: $role) {
                        ForEach(AppUser.UserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Новый пользователь")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        createUser()
                    }
                    .disabled(email.isEmpty || password.isEmpty || name.isEmpty)
                }
            }
        }
    }
    
    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else { return }
            
            let newUser = AppUser(
                id: user.uid,
                name: name,
                email: email,
                role: role
            )
            
            userService.saveUser(newUser) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    dismiss()
                }
            }
        }
    }
}
