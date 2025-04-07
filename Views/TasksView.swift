//
//  TasksView.swift
//  NikitaCRM
//

import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @EnvironmentObject private var userService: UserService
    @State private var showingNewTask = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTasks) { task in
                    TaskRowView(task: task) {
                        viewModel.toggleTaskStatus(task) { error in
                            if let error = error {
                                errorMessage = "Ошибка изменения статуса: \(error.localizedDescription)"
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteTask(task) { error in
                                if let error = error {
                                    errorMessage = "Ошибка удаления задачи: \(error.localizedDescription)"
                                }
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Задачи")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Фильтр", selection: $viewModel.selectedFilter) {
                            ForEach(TasksViewModel.TaskFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    
                    if userService.isCurrentUserAdmin || userService.currentUser?.role == .manager {
                        Button {
                            showingNewTask = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewTask) {
                TaskEditorView(task: .constant(nil)) { newTask in
                    viewModel.addTask(newTask) { error in
                        if let error = error {
                            errorMessage = "Ошибка создания задачи: \(error.localizedDescription)"
                        } else {
                            showingNewTask = false
                        }
                    }
                }
                .environmentObject(userService)
            }
            .alert("Ошибка", isPresented: .constant(!errorMessage.isEmpty)) {
                Button("OK") { errorMessage = "" }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(task.isOverdue ? .red : .gray)
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == .completed ? .green : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
