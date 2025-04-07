//
//  CalendarView.swift
//  NikitaCRM
//
//  Created by Никита Черников on 02.04.2025.
//
import SwiftUI
import FirebaseDatabase
import Combine

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingAddEvent = false
    @State private var newEventTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Выберите дату",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    if let events = viewModel.events[viewModel.selectedDate] {
                        ForEach(events, id: \.id) { event in
                            HStack {
                                Text(event.title)
                                Spacer()
                                Text(event.time, style: .time)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteEvent(event)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        Text("Нет событий на выбранную дату")
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Календарь")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                VStack(spacing: 20) {
                    TextField("Название события", text: $newEventTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Добавить") {
                        viewModel.addEvent(title: newEventTitle)
                        newEventTitle = ""
                        showingAddEvent = false
                    }
                    .disabled(newEventTitle.isEmpty)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchEvents()
            }
        }
    }
}

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var events: [Date: [CalendarEvent]] = [:]
    
    private let db = Database.database().reference().child("calendarEvents")
    private var cancellables = Set<AnyCancellable>()
    
    func fetchEvents() {
        db.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var newEvents: [Date: [CalendarEvent]] = [:]
            
            if let value = snapshot.value as? [String: Any] {
                for (_, eventData) in value {
                    if let dict = eventData as? [String: Any],
                       let dateInterval = dict["date"] as? TimeInterval,
                       let title = dict["title"] as? String,
                       let id = dict["id"] as? String {
                        let date = Date(timeIntervalSince1970: dateInterval)
                        let event = CalendarEvent(id: id, title: title, date: date)
                        
                        let calendar = Calendar.current
                        let normalizedDate = calendar.startOfDay(for: date)
                        
                        if newEvents[normalizedDate] != nil {
                            newEvents[normalizedDate]?.append(event)
                        } else {
                            newEvents[normalizedDate] = [event]
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.events = newEvents
            }
        }
    }
    
    func addEvent(title: String) {
        let eventId = UUID().uuidString
        let eventData: [String: Any] = [
            "id": eventId,
            "title": title,
            "date": selectedDate.timeIntervalSince1970
        ]
        
        db.child(eventId).setValue(eventData)
    }
    
    func deleteEvent(_ event: CalendarEvent) {
        db.child(event.id).removeValue()
    }
}

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let date: Date
    
    var time: Date { date }
}
