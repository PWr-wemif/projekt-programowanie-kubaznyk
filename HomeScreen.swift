import SwiftUI
import CoreData

struct HomeScreen: View {
    @StateObject private var eventDataController = EventDataController()
    @StateObject private var tenantDataController = TenantDataController()
    @StateObject private var apartmentDataController = ApartmentDataController()
    @State private var isAddingApartment = false


    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("PropertyManager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 50)
                    .padding(.bottom, 5)
                
                CalendarEventsView(eventDataController: eventDataController)
                    .padding(.top, 20)
                
                // Najemcy
                NavigationLink(destination: TenantView().environmentObject(tenantDataController)) {
                    HStack {
                        Text("Najemcy")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Zobacz wszystkich")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.all, 20)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(tenantDataController.tenants) { tenant in
                            NavigationLink(destination: TenantDetailsView(tenant: tenant, dataController: tenantDataController)) {
                                TenantRowView(tenant: tenant)
                            }

                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                
             
                
                NavigationLink(destination: ApartmentScreen()) {
                                 HStack {
                                     Text("Wybierz mieszkanie")
                                         .font(.system(size: 23))

                                     Spacer()

                                     Text("Pokaż wszystkie")
                                         .font(.footnote)
                                         .foregroundColor(Color.gray)
                                 }
                                 .padding(.all, 20)
                             }

                            }
                         .onAppear {
                             eventDataController.loadEventsFromCoreData()
                         }
                         .navigationBarTitle("", displayMode: .inline)
                     }
                 }
             }
              

struct CalendarEventsView: View {
        @ObservedObject var eventDataController: EventDataController
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Wydarzenia")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                List {
                    ForEach(eventDataController.events) { event in
                        VStack(alignment: .leading) {
                            Text("Data: \(formattedDate(event.date))")
                            Text("Opis: \(event.eventDescription)")
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                    }
                }
                .frame(height: 150)
                .listStyle(PlainListStyle())
            }
        }
        
        private func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        }
    }
    struct ApartmentListView: View {
        @ObservedObject var dataController: ApartmentDataController
        @State private var isAddingApartment = false

        var body: some View {
            NavigationView {
                List {
                    ForEach(dataController.apartments) { apartment in
                        NavigationLink(destination: ApartmentDetailView(apartment: apartment, dataController: dataController)) {
                            Text(apartment.name)
                        }
                    }
                }
                .navigationTitle("Lista Mieszkań")
                .navigationBarItems(trailing:
                    Button(action: {
                        isAddingApartment = true
                    }) {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $isAddingApartment) {
                   
                }
            }
        }
    }

struct HomeScreen_Previews: PreviewProvider {
        static var previews: some View {
            HomeScreen()
        }
    }


