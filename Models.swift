//
//  Models.swift
//  NikitaCRM
//

import Foundation

struct AppUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let email: String
    var role: UserRole
    
    enum UserRole: String, Codable, CaseIterable {
        case admin = "admin"
        case manager = "manager"
        case employee = "employee"
        
        var displayName: String {
            switch self {
            case .admin: return "Администратор"
            case .manager: return "Менеджер"
            case .employee: return "Сотрудник"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Task: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var dueDate: Date
    var status: Status
    var assignedUserIds: [String]
    
    enum Status: String, Codable, CaseIterable {
        case active = "active"
        case completed = "completed"
        case archived = "archived"
        
        var displayName: String {
            switch self {
            case .active: return "Активная"
            case .completed: return "Завершена"
            case .archived: return "Архивная"
            }
        }
    }
    
    var isOverdue: Bool {
        dueDate < Date() && status == .active
    }
}

struct Post: Identifiable, Codable {
    var id: String?
    var authorName: String
    var text: String
    var date: Date
    var authorId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorName
        case text
        case date
        case authorId
    }
}
