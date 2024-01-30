import SwiftUI
import Combine

@main
struct Project_Management_AppApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @StateObject private var dataController = ApartmentDataController()


    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(dataController)
            } else {
                LoginView()
            }
        }
    }
}
