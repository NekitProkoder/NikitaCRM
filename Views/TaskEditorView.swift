import SwiftUI
import FirebaseAuth

struct TaskEditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userService: UserService
    @Binding var task: Task?
    let onSave: (Task) -> Void
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedUserIds: Set<String> = []
    @State private var status: Task.Status = .active
    
    private var assignableUsers: [AppUser] {
        guard let currentId = Auth.auth().currentUser?.uid else { return [] }
        return userService.users.filter { $0.id != currentId }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    TextField("Название задачи", text: $title)
                    TextField("Описание", text: $description)
                    DatePicker("Срок выполнения", selection: $dueDate, displayedComponents: .date)
                }
                
                Section("Статус") {
                    Picker("Статус", selection: $status) {
                        ForEach(Task.Status.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Ответственные") {
                    if assignableUsers.isEmpty {
                        Text("Нет доступных пользователей")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(assignableUsers) { user in
                            HStack {
                                Text(user.name)
                                Spacer()
                                if selectedUserIds.contains(user.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleUserSelection(user.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? "Новая задача" : "Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let task = task {
                    title = task.title
                    description = task.description
                    dueDate = task.dueDate
                    status = task.status
                    selectedUserIds = Set(task.assignedUserIds)
                }
            }
        }
    }
    
    private func toggleUserSelection(_ userId: String) {
        if selectedUserIds.contains(userId) {
            selectedUserIds.remove(userId)
        } else {
            selectedUserIds.insert(userId)
        }
    }
    
    private func saveTask() {
        let newTask = Task(
            id: task?.id,
            title: title,
            description: description,
            dueDate: dueDate,
            status: status,
            assignedUserIds: Array(selectedUserIds)
        )
        onSave(newTask)
    }
}
