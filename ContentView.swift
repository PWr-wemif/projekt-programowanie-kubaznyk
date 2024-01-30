import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("username") private var username: String = ""
    

    var body: some View {
        
        NavigationStack{
            
            ZStack{
                TabView{
                    TabView{
                        HomeScreen()
                    }
                    .tabItem { Image(systemName: "house.fill")
                    }
                    TabView{
                        AgreementsView()
                    }
                    .tabItem { Image(systemName: "doc.plaintext.fill") }
                    TabView{
                        CalendarScreen()
                    }
                    
                    
                    .tabItem { Image(systemName: "calendar") }
                    TabView{
                        SettingsView()
                    }
                    
                    .tabItem { Image(systemName: "person.crop.circle.fill") }
                   }
                
                .accentColor(.black)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    CircularImageView(name: "5", size: 42)
                    Text("Witaj, \(username)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
