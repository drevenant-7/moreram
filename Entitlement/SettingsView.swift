//
//  SettingsView.swift
//  Entitlement
//
//  Created by s s on 2025/3/14.
//

import SwiftUI
import StosSign

struct SettingsView: View {

    @State var email = ""
    @State var teamId = ""
    @StateObject var viewModel : LoginViewModel
    @EnvironmentObject private var sharedModel : SharedModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    

    var body: some View {
        Form {

            Section {
                if sharedModel.isLogin {
                    HStack {
                        Text("អ៊ីមែល")
                        Spacer()
                        Text(email)
                    }
                    HStack {
                        Text("លេខសម្គាល់ក្រុម")
                        Spacer()
                        Text(teamId)
                    }
                } else {
                    Button("ចូលប្រើ") {
                        viewModel.loginModalShow = true
                    }
                }
            } header: {
                Text("គណនី")
            }
            
            Section {
                HStack {
                    Text("អាសយដ្ឋានម៉ាស៊ីនមេ Anisette")
                    Spacer()
                    TextField("", text: $sharedModel.anisetteServerURL)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                Button("សម្អាត Keychain") {
                    cleanUp()
                }
            } footer: {
                Text("ប្រសិនបើមានបញ្ហាកើតឡើងក្នុងពេលចូលប្រើ សូមព្យាយាមសម្អាត keychain រួចបើកកម្មវិធីឡើងវិញ។")
            }
        }
        alert("alert("កំហុស"ហុស", isPresented: $errorShow){
            Button("យល់ព្រម".loc, action: {
            })
        } message: {
            Text(errorInfo)
        }
        
        .sheet(isPresented: $viewModel.loginModalShow) {
            loginModal
        }
    }
    
    var loginModal: some View {
        NavigationView {
            Form {
                Section {
                    TextField("", text: $viewModel.appleID)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("Apple ID")
                }
                Section {
                    SecureField("", text: $viewModel.password)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("Password")
                }
                if viewModel.needVerificationCode {
                    Section {
                        TextField("", text: $viewModel.verificationCode)
                    } header: {
                        Text("Verification Code")
                    }
                }
                Section {
                    Button("Continue") {
                        Task{ await loginButtonClicked() }
                    }
                }
                
                Section {
                    Text(viewModel.logs)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Text("Debugging")
                }
            }
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        viewModel.loginModalShow = false
                    }
                }
            }
        }
        .onAppear {
            if let email = Keychain.shared.appleIDEmailAddress, let password = Keychain.shared.appleIDPassword {
                viewModel.appleID = email
                viewModel.password = password
            }
        }
    }
    
    func loginButtonClicked() async {
        do {
            if viewModel.needVerificationCode {
                viewModel.submitVerficationCode()
                return
            }
            
            let result = try await viewModel.authenticate()
            if result {
                viewModel.loginModalShow = false
                email = sharedModel.account!.appleID
                teamId = sharedModel.team!.identifier
            }
            
        } catch {
            errorInfo = error.localizedDescription
            errorShow = true
        }
    }
    
    func cleanUp() {
        Keychain.shared.adiPb = nil
        Keychain.shared.identifier = nil
        Keychain.shared.appleIDPassword = nil
        Keychain.shared.appleIDEmailAddress = nil
    }
    
}
