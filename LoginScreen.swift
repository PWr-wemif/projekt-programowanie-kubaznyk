import SwiftUI

struct LoginView: View {
    @AppStorage("username") private var storedUsername: String = ""
    @AppStorage("password") private var storedPassword: String = ""

    @State private var enteredUsername: String = ""
    @State private var enteredPassword: String = ""
    @State private var loginError: Bool = false

    @State private var isLogged: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Login", text: $enteredUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Hasło", text: $enteredPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    login()
                }) {
                    Text("Zaloguj się")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .padding()

                if loginError {
                    Text("Błąd logowania. Sprawdź wprowadzone dane.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            .navigationBarTitle("Logowanie", displayMode: .inline)
            .background(NavigationLink("", destination: ContentView(), isActive: $isLogged))
        }
    }

    func login() {
        if enteredUsername == storedUsername && enteredPassword == storedPassword {
            loginError = false
            isLogged = true
        } else {
            loginError = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
