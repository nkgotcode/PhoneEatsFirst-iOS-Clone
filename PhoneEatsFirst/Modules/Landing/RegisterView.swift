//
//  RegisterView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/10/21.
//

import Resolver
import SwiftUI
import ToastUI
import WebKit

struct RegisterView: View {
  @Injected private var repository: DataRepository

  @Binding var linkActive: Bool

  @State private var firstName: String = ""
  @State private var lastName: String = ""
  @State private var username: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""
  @State private var acceptLicense: Bool = false

  @State private var showLoadingIndicator: Bool = false
  @State private var showFailedAlert: Bool = false
  @State private var showLicensePage: Bool = false
  @State private var showPrivacyPage: Bool = false

  @StateObject private var webViewStore = WebViewStore()

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack {
          Spacer()

          Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)

          Spacer()

          VStack {
            HStack {
              Image(systemName: "doc.plaintext")
                .frame(width: 18, height: 18)
              TextField("First Name", text: $firstName)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            HStack {
              Image(systemName: "doc.plaintext")
                .frame(width: 18, height: 18)
              TextField("Last Name", text: $lastName)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            HStack {
              Image(systemName: "person")
                .frame(width: 18, height: 18)
              TextField("Username", text: $username)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            HStack {
              Image(systemName: "at")
                .frame(width: 18, height: 18)
              TextField("Email", text: $email)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            HStack {
              Image(systemName: "key")
                .frame(width: 18, height: 18)
              SecureField("Password", text: $password)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            HStack {
              Image(systemName: "key")
                .frame(width: 18, height: 18)
              SecureField("Confirm Password", text: $confirmPassword)
                .autocapitalization(.none)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 14)
                .foregroundColor(Color(.secondarySystemBackground))
            )

            Toggle(isOn: $acceptLicense) {
              HStack(spacing: 4) {
                Text("I accept the")
                Button {
                  showLicensePage = true
                } label: {
                  Text("Terms of Service").bold()
                }
                Text("and the")
                Button {
                  showLicensePage = true
                } label: {
                  Text("Privacy Policy").bold()
                }
              }
              .sheet(isPresented: $showLicensePage) {
                WebWrapperView(
                  webViewStore: webViewStore,
                  title: "Terms of Service",
                  url: "https://www.phoneeatsfirst.com/terms-of-service"
                )
              }
              .sheet(isPresented: $showPrivacyPage) {
                WebWrapperView(
                  webViewStore: webViewStore,
                  title: "Privacy Policy",
                  url: "https://www.phoneeatsfirst.com/privacy-policy-4"
                )
              }
            }
          }

          Spacer()

          ThirdPartyAuthView(title: "Or, register with...")

          Spacer()

          Button {
            showLoadingIndicator = true
            repository.register(
              username: username,
              firstName: firstName,
              lastName: lastName,
              email: email,
              password: password
            ) { result in
              showLoadingIndicator = false
              if result {
                linkActive = false
              } else {
                showFailedAlert = true
              }
            }

          } label: {
            Text("Register")
              .bold()
              .foregroundColor(.white)
              .padding()
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
              )
          }
          .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          .hoverEffect(.highlight)
        } // VStack
        .padding()
        .frame(width: geometry.size.width, height: geometry.size.height)
      } // ScrollView
    } // GeometryReader
    .toast(isPresented: $showLoadingIndicator) {
      ToastView("Loading")
        .toastViewStyle(IndefiniteProgressToastViewStyle())
    }
    .alert(isPresented: $showFailedAlert) {
      Alert(title: Text("Failed"),
            message: Text("Failed to register the account. Please try again later"))
    }
    .navigationTitle("Register")
  }
}

struct RegisterView_Previews: PreviewProvider {
  static var previews: some View {
    RegisterView(linkActive: .constant(false))
  }
}
