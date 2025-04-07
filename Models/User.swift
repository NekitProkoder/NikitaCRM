//
//  User.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//
import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let email: String
    var role: Role
    
    enum Role: String, Codable, Equatable, Hashable {
        case admin = "admin"
        case manager = "manager"
        case employee = "employee"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
