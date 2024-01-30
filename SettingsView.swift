
import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("password") private var password: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dane logowania")) {
                    TextField("Login", text: $username)
                    SecureField("Hasło", text: $password)
                }

                Section {
                    Button(action: {
                        saveLoginData()
                    }) {
                        Text("Zapisz zmiany")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .navigationBarTitle("Ustawienia", displayMode: .inline)
        }
    }

    func saveLoginData() {
       print("Dane zapisane: \(username), \(password)")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
