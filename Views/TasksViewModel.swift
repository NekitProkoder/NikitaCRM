//
//  TasksViewModel.swift
//  NikitaCRM
//

import Firebase
import FirebaseDatabase
import Combine

final class TasksViewModel: ObservableObject {
    @Published private(set) var allTasks: [Task] = []
    @Published private(set) var filteredTasks: [Task] = []
    @Published var searchText = ""
    @Published var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "Все"
        case active = "Активные"
        case completed = "Завершенные"
        case overdue = "Просроченные"
    }
    
    private let db = Database.database().reference().child("tasks")
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupTasksListener()
        setupBindings()
    }
    
    // Публичные методы для работы с задачами
    func addTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        let taskData = try? JSONEncoder().encode(task)
        if let dict = try? JSONSerialization.jsonObject(with: taskData ?? Data()) as? [String: Any] {
            db.childByAutoId().setValue(dict, withCompletionBlock: { error, _ in
                completion(error)
            })
        } else {
            completion(NSError(domain: "TasksViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка кодирования задачи"]))
        }
    }
    
    func toggleTaskStatus(_ task: Task, completion: @escaping (Error?) -> Void) {
        guard let taskId = task.id else {
            completion(NSError(domain: "TasksViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует ID задачи"]))
            return
        }
        let newStatus: Task.Status = task.status == .active ? .completed : .active
        db.child(taskId).updateChildValues(["status": newStatus.rawValue], withCompletionBlock: { error, _ in
            completion(error)
        })
    }
    
    func deleteTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        guard let taskId = task.id else {
            completion(NSError(domain: "TasksViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Отсутствует ID задачи"]))
            return
        }
        db.child(taskId).removeValue(completionBlock: { error, _ in
            completion(error)
        })
    }
    
    private func setupTasksListener() {
        db.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            do {
                let tasks = try self.parseTasks(snapshot)
                DispatchQueue.main.async {
                    self.allTasks = tasks
                }
            } catch {
                print("Error parsing tasks: \(error)")
            }
        }
    }
    
    private func parseTasks(_ snapshot: DataSnapshot) throws -> [Task] {
        guard let value = snapshot.value as? [String: Any] else { return [] }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return try value.compactMap { key, value -> Task? in
            guard let dict = value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: dict) else {
                return nil
            }
            var task = try decoder.decode(Task.self, from: data)
            task.id = key
            return task
        }
    }
    
    private func setupBindings() {
        $searchText
            .combineLatest($selectedFilter, $allTasks)
            .map { (text, filter, tasks) in
                self.filterTasks(tasks, text: text, filter: filter)
            }
            .assign(to: &$filteredTasks)
    }
    
    private func filterTasks(_ tasks: [Task], text: String, filter: TaskFilter) -> [Task] {
        var result = tasks
        
        if !text.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(text) ||
                $0.description.localizedCaseInsensitiveContains(text)
            }
        }
        
        switch filter {
        case .all: break
        case .active: result = result.filter { $0.status == .active }
        case .completed: result = result.filter { $0.status == .completed }
        case .overdue: result = result.filter { $0.isOverdue }
        }
        
        return result.sorted { $0.dueDate < $1.dueDate }
    }
}
