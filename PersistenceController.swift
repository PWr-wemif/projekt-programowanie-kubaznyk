import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "EventModel")

      

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Błąd inicjalizacji magazynu Core Data \(error)")
            }
        }
    }
}
