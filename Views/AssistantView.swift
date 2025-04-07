//
//  AssistantView.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//

import SwiftUI

struct AssistantView: View {
    let faqItems = [
        FAQItem(
            question: "Как добавить задачу?",
            answer: "Перейдите на вкладку 'Задачи' и нажмите кнопку '+' в правом верхнем углу. Заполните все необходимые поля и сохраните."
        ),
        FAQItem(
            question: "Как изменить статус задачи?",
            answer: "Нажмите на задачу в списке и выберите новый статус из доступных вариантов."
        ),
        FAQItem(
            question: "Как создать новый пост?",
            answer: "На вкладке 'Новости' нажмите кнопку '+' и введите текст поста."
        ),
        FAQItem(
            question: "Как добавить событие в календарь?",
            answer: "Выберите дату в календаре и нажмите кнопку '+' для добавления нового события."
        ),
        FAQItem(
            question: "Как изменить свою роль?",
            answer: "Роль пользователя может изменить только администратор системы. Обратитесь к вашему администратору."
        )
    ]
    
    @State private var expandedItems: Set<String> = []
    
    var body: some View {
        NavigationStack {
            List(faqItems) { item in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedItems.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedItems.insert(item.id)
                            } else {
                                expandedItems.remove(item.id)
                            }
                        }
                    ),
                    content: {
                        Text(item.answer)
                            .padding(.vertical, 8)
                    },
                    label: {
                        Text(item.question)
                            .font(.headline)
                    }
                )
            }
            .navigationTitle("Помощник")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        expandedItems = Set(faqItems.map { $0.id })
                    } label: {
                        Text("Развернуть все")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        expandedItems = []
                    } label: {
                        Text("Свернуть все")
                    }
                }
            }
        }
    }
}

struct FAQItem: Identifiable {
    let id = UUID().uuidString
    let question: String
    let answer: String
}

struct AssistantView_Previews: PreviewProvider {
    static var previews: some View {
        AssistantView()
    }
}
