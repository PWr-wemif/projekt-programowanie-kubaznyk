import SwiftUI
import CoreData
import Combine

struct ApartmentModel: Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var rent: Double
    var tenant: Tenant?  // zmiana typu najemcy na Tenant bo odczytuje z coredata
    var utilities: Double
}
class SelectionManager: ObservableObject {
    var selectedTenant = PassthroughSubject<Tenant?, Never>()
    
}
class ApartmentDataController: ObservableObject {
    
    @Published var apartments: [ApartmentModel] = []
    func loadTenantsFromCoreData() -> [Tenant] {
            let context = PersistenceController.shared.container.viewContext

            do {
                let coreDataTenants = try context.fetch(Tenant.fetchRequest()) as! [Tenant]
                return coreDataTenants
            } catch {
                print("Błąd podczas wczytywania najemców z Core Data: \(error.localizedDescription)")
                return []
            }
        }
    func addApartment(name: String, address: String, rent: Double, tenant: Tenant?, utilities: Double) {
        let newApartment = ApartmentModel(name: name, address: address, rent: rent, tenant: tenant, utilities: utilities)
        apartments.append(newApartment)

        saveApartmentToCoreData(apartment: newApartment)
    }
        func removeApartment(at index: Int) {
        let removedApartment = apartments.remove(at: index)
        removeApartmentFromCoreData(apartment: removedApartment)
    }

    private func saveApartmentToCoreData(apartment: ApartmentModel) {
        let context = PersistenceController.shared.container.viewContext

        let coreDataApartment = Apartment(context: context)
        coreDataApartment.id = apartment.id
        coreDataApartment.name = apartment.name
        coreDataApartment.address = apartment.address
        coreDataApartment.rent = apartment.rent
        coreDataApartment.tenantRelationship = apartment.tenant
        coreDataApartment.utilities = apartment.utilities

        do {
            try context.save()
        } catch {
            print("Błąd podczas zapisywania apartamentu do Core Data: \(error.localizedDescription)")
        }
    }

    private func removeApartmentFromCoreData(apartment: ApartmentModel) {
        let context = PersistenceController.shared.container.viewContext

        do {
            if let coreDataApartment = try fetchCoreDataApartment(with: apartment.id, in: context) {
                context.delete(coreDataApartment)
                try context.save()
            }
        } catch {
            print("Błąd podczas usuwania apartamentu z Core Data: \(error.localizedDescription)")
        }
    }

    private func fetchCoreDataApartment(with id: UUID, in context: NSManagedObjectContext) throws -> Apartment? {
        let fetchRequest: NSFetchRequest<Apartment> = Apartment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try context.fetch(fetchRequest).first
    }

    func loadApartmentsFromCoreData() {
        let context = PersistenceController.shared.container.viewContext

        do {
            let coreDataApartments = try context.fetch(Apartment.fetchRequest()) as! [Apartment]
            apartments = coreDataApartments.map {
                ApartmentModel(
                    id: $0.id!,
                    name: $0.name!,
                    address: $0.address!,
                    rent: $0.rent,
                    tenant: $0.tenantRelationship,
                    utilities: $0.utilities
                )
            }
        } catch {
            print("Błąd podczas wczytywania apartamentów z Core Data: \(error.localizedDescription)")
        }
    }
}

struct ApartmentScreen: View {
    @StateObject private var apartmentDataController = ApartmentDataController()

    var body: some View {
        NavigationView {
            VStack {
                Text("Lista Apartamentów")
                    .font(.largeTitle)
                    .padding()

                List {
                    ForEach(apartmentDataController.apartments.indices, id: \.self) { index in
                        NavigationLink(
                            destination: ApartmentDetailView(apartment: apartmentDataController.apartments[index], dataController: apartmentDataController)
                        ) {
                            ApartmentRowView(apartment: apartmentDataController.apartments[index])
                        }
                    }
                    .onDelete { indexSet in
                        apartmentDataController.removeApartment(at: indexSet.first ?? 0)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarItems(trailing:
                NavigationLink(
                    destination: AddApartmentView(dataController: apartmentDataController),
                    label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                            .padding()
                    }
                )
            )

            .onAppear {
                apartmentDataController.loadApartmentsFromCoreData()
            }
        }
    }
}
struct ApartmentDetailView: View {
    let apartment: ApartmentModel
    let dataController: ApartmentDataController

    var body: some View {
        VStack {
            Text("Nazwa: \(apartment.name)")
                .font(.title)
            Text("Adres: \(apartment.address)")
                .font(.headline)
            Text("Czynsz: \(apartment.rent)")
                .font(.subheadline)
            Text("Najemca: \(apartment.tenant?.name ?? "Brak najemcy")")
                            .font(.subheadline)
            Text("Opłaty: \(apartment.utilities)")
                .font(.subheadline)

            Spacer()

            Button("Usuń Apartament") {
                dataController.removeApartment(at: dataController.apartments.firstIndex(where: { $0.id == apartment.id }) ?? 0)
            }
            .foregroundColor(.red)
        }
        .padding()
        .navigationTitle(apartment.name)
    }
}
struct ApartmentRowView: View {
    let apartment: ApartmentModel

    var body: some View {
        HStack {
            Image(systemName: "house.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(apartment.name)
                    .font(.headline)
                Text("Adres: \(apartment.address)")
                    .font(.subheadline)
            }
        }
    }
}
struct AddApartmentView: View {
    @ObservedObject var dataController: ApartmentDataController
    @State private var newName = ""
    @State private var newAddress = ""
    @State private var newRent = ""
    @State private var selectedTenantID: UUID?
    @State private var newUtilities = ""
    @State private var tenants: [Tenant] = []

    var body: some View {
        Form {
            Section(header: Text("Nowy Apartament")) {
                TextField("Nazwa", text: $newName)
                TextField("Adres", text: $newAddress)
                TextField("Czynsz", text: $newRent)
                    .keyboardType(.decimalPad)

                Picker("Najemca", selection: $selectedTenantID) {
                    ForEach(tenants, id: \.id) { tenant in
                        Text(tenant.name ?? "").tag(tenant.id)
                    }
                }

                TextField("Opłaty", text: $newUtilities)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Dodaj Apartament") {
                    let selectedTenant = tenants.first { $0.id == selectedTenantID }
                    dataController.addApartment(
                        name: newName,
                        address: newAddress,
                        rent: Double(newRent) ?? 0.0,
                        tenant: selectedTenant,
                        utilities: Double(newUtilities) ?? 0.0
                    )

                    newName = ""
                    newAddress = ""
                    newRent = ""
                    newUtilities = ""
                }
            }
        }
        .navigationTitle("Dodaj Apartament")
        .onAppear {
            tenants = dataController.loadTenantsFromCoreData()
        }
    }
}
    struct ApartmentScreen_Previews: PreviewProvider {
        static var previews: some View {
            ApartmentScreen()
        }
    }

