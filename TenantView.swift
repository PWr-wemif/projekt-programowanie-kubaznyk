import SwiftUI
import CoreData

public class TenantDataController: ObservableObject {
    @Published public var tenants: [TenantModel] = []
    

    func addTenant(name: String, birthDate: Date, contactNumber: String) {
        let newTenant = TenantModel(name: name, birthDate: birthDate, contactNumber: contactNumber)
        tenants.append(newTenant)

        saveTenantToCoreData(tenant: newTenant)
    }

    func removeTenant(at index: Int) {
        let removedTenant = tenants.remove(at: index)
        removeTenantFromCoreData(tenant: removedTenant)
    }

    private func saveTenantToCoreData(tenant: TenantModel) {
        let context = PersistenceController.shared.container.viewContext

        let coreDataTenant = Tenant(context: context)
        coreDataTenant.id = UUID()  // tworzenie nowego uuid dla kazdego nowego najemcy 
        coreDataTenant.name = tenant.name
        coreDataTenant.birthDate = tenant.birthDate
        coreDataTenant.contactNumber = tenant.contactNumber

        do {
            try context.save()
        } catch {
            print("Error saving tenant to Core Data: \(error.localizedDescription)")
        }
    }
    

    private func removeTenantFromCoreData(tenant: TenantModel) {
        let context = PersistenceController.shared.container.viewContext

        do {
            if let coreDataTenant = try fetchCoreDataTenant(with: tenant.id, in: context) {
                context.delete(coreDataTenant)
                try context.save()
            }
        } catch {
            print("Error removing tenant from Core Data: \(error.localizedDescription)")
        }
    }

    private func fetchCoreDataTenant(with id: UUID, in context: NSManagedObjectContext) throws -> Tenant? {
        let fetchRequest: NSFetchRequest<Tenant> = Tenant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try context.fetch(fetchRequest).first
    }

    func loadTenantsFromCoreData() {
        let context = PersistenceController.shared.container.viewContext

        do {
            let coreDataTenants = try context.fetch(Tenant.fetchRequest()) as! [Tenant]
            tenants = coreDataTenants.map { tenantEntity in
                TenantModel(
                    id: tenantEntity.id ?? UUID(), // jeśli ID jest nil, użyje nowego UUID
                    name: tenantEntity.name ?? "",
                    birthDate: tenantEntity.birthDate ?? Date(),
                    contactNumber: tenantEntity.contactNumber ?? ""
                )
            }
        } catch {
            print("Error loading tenants from Core Data: \(error.localizedDescription)")
        }
    }
}



public struct TenantModel: Identifiable {
    public var id = UUID()
    public var name: String
    public var birthDate: Date
    public var contactNumber: String
}

struct TenantView: View {
    @StateObject private var dataController = TenantDataController()

    var body: some View {
        NavigationView {
            List {
                ForEach(dataController.tenants) { tenant in
                    NavigationLink(destination: TenantDetailsView(tenant: tenant, dataController: dataController)) {
                        TenantRowView(tenant: tenant)
                    }
                }
                .onDelete { indexSet in
                    dataController.removeTenant(at: indexSet.first ?? 0)
                }
            }
            .navigationTitle("Najemcy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTenantView(dataController: dataController)) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .onAppear {
            dataController.loadTenantsFromCoreData()
        }
    }
}

struct AddTenantView: View {
    @ObservedObject var dataController: TenantDataController

    @State private var name: String = ""
    @State private var birthDate = Date()
    @State private var contactNumber: String = ""

    var body: some View {
        Form {
            Section(header: Text("Nowy Najemca")) {
                TextField("Imię i Nazwisko", text: $name)
                DatePicker("Data urodzenia", selection: $birthDate, displayedComponents: .date)
                TextField("Numer kontaktowy", text: $contactNumber)
            }

            Section {
                Button("Dodaj Najemcę") {
                    dataController.addTenant(name: name, birthDate: birthDate, contactNumber: contactNumber)
                }
            }
        }
        .navigationTitle("Dodaj Najemcę")
    }
}

struct TenantDetailsView: View {
    let tenant: TenantModel
    let dataController: TenantDataController

    var body: some View {
        VStack {
            Text("Imię i Nazwisko: \(tenant.name)")
                .font(.title)
            Text("Data urodzenia: \(formattedDate(tenant.birthDate))")
                .font(.headline)
            Text("Numer kontaktowy: \(tenant.contactNumber)")
                .font(.subheadline)

            Spacer()

            Button("Usuń Najemcę") {
                dataController.removeTenant(at: dataController.tenants.firstIndex(where: { $0.id == tenant.id }) ?? 0)
            }
            .foregroundColor(.red)
        }
        .padding()
        .navigationTitle(tenant.name)
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct TenantRowView: View {
    let tenant: TenantModel

    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(tenant.name)
                    .font(.headline)
                Text("Data urodzenia: \(formattedDate(tenant.birthDate))")
                    .font(.subheadline)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct TenantView_Previews: PreviewProvider {
    static var previews: some View {
        TenantView()
    }
}
