import SwiftUI
import CoreData

struct EventModel: Identifiable {
    var id = UUID()
    var date: Date
    var eventDescription: String
}

class EventDataController: ObservableObject {
    @Published var events: [EventModel] = []

    func addEvent(date: Date, eventDescription: String) {
        let newEvent = EventModel(date: date, eventDescription: eventDescription)
        events.append(newEvent)

        // zapisuje sobie do core daty
        saveEventToCoreData(event: newEvent)
    }

    func removeEvent(at index: Int) {
        let removedEvent = events.remove(at: index)

        // usuwa z cD
        removeEventFromCoreData(event: removedEvent)
    }

    private func saveEventToCoreData(event: EventModel) {
        let context = PersistenceController.shared.container.viewContext

        let coreDataEvent = Event(context: context)
        coreDataEvent.id = event.id
        coreDataEvent.date = event.date
        coreDataEvent.eventDescription = event.eventDescription

        do {
            try context.save()
        } catch {
            print("Błąd podczas zapisywania wydarzenia do Core Data: \(error.localizedDescription)")
        }
    }

    private func removeEventFromCoreData(event: EventModel) {
        let context = PersistenceController.shared.container.viewContext

        do {
            if let coreDataEvent = try fetchCoreDataEvent(with: event.id, in: context) {
                context.delete(coreDataEvent)
                try context.save()
            }
        } catch {
            print("Błąd podczas usuwania wydarzenia z Core Data: \(error.localizedDescription)")
        }
    }

    private func fetchCoreDataEvent(with id: UUID, in context: NSManagedObjectContext) throws -> Event? {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try context.fetch(fetchRequest).first
    }

    func loadEventsFromCoreData() {
        let context = PersistenceController.shared.container.viewContext

        do {
            let coreDataEvents = try context.fetch(Event.fetchRequest()) as! [Event]
            events = coreDataEvents.map { EventModel(id: $0.id!, date: $0.date!, eventDescription: $0.eventDescription!) }
        } catch {
            print("Błąd podczas wczytywania wydarzeń z Core Data: \(error.localizedDescription)")
        }
    }
}

struct CalendarScreen: View {
    @State private var selectedDate = Date()
    @State private var newEventText = ""
    @StateObject private var eventDataController = EventDataController()

    var body: some View {
        VStack {
            Text("Harmonogram")
                .font(.largeTitle)
                .padding()

            DatePicker("Wybierz datę", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())

            TextField("Dodaj nowe wydarzenie", text: $newEventText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Dodaj wydarzenie") {
                eventDataController.addEvent(date: selectedDate, eventDescription: newEventText)
                newEventText = ""
            }

            List {
                ForEach(eventDataController.events.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Data: \(formattedDate(eventDataController.events[index].date))")
                        Text("Opis: \(eventDataController.events[index].eventDescription)")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .overlay(
                        Button(action: {
                            eventDataController.removeEvent(at: index)
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                        .padding(.trailing, 10)
                        , alignment: .trailing
                    )
                    .padding(.vertical, 5)
                }
            }
            .frame(height: 110)
            .listStyle(PlainListStyle())

        }
        .padding()
        .onAppear {
            eventDataController.loadEventsFromCoreData()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct CalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreen()
    }
}
