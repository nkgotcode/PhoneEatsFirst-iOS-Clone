//
//  LoginView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/10/21.
//

import Resolver
import SwiftUI
import ToastUI

struct LoginView: View {
  @Injected private var repository: DataRepository

  @Binding var linkActive: Bool

  @State private var email: String = ""
  @State private var password: String = ""

  @State private var showLoadingIndicator: Bool = false
  @State private var showFailedAlert: Bool = false

  var body: some View {
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack {
          Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)

          Spacer()

          VStack {
            HStack {
              Image(systemName: "person")
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
          }
          HStack {
            Spacer()
            Button {
              // forgot password
            } label: {
              Text("Forgot password?")
            }
            .contentShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .hoverEffect(.highlight)
          }

          Spacer()

          ThirdPartyAuthView(title: "Or, login with...")

          Spacer()

          Button {
            showLoadingIndicator = true
            repository.login(email: email, password: password) { result in
              showLoadingIndicator = false
              if result {
                linkActive = false
              } else {
                // TODO: attempt to present

                showFailedAlert = true
              }
            }
          } label: {
            Text("Login")
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

          NavigationLink {
            RegisterView(linkActive: $linkActive)
          } label: {
            HStack(spacing: 4) {
              Text("New to PhoneEatsFirst?")
                .foregroundColor(Color(.label))
              Text("Sign up").bold()
            }
          }
          .isDetailLink(false)
          .contentShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
          .hoverEffect(.highlight)
        } // VStack
        .padding()
        .frame(width: geometry.size.width, height: geometry.size.height)
      } // ScrollView
//      .frame(width: geometry.size.width, height: geometry.size.height)
//      .frame(maxWidth: .infinity, maxHeight: .infinity)
    } // GeometryReader
    .toast(isPresented: $showLoadingIndicator) {
      ToastView("Loading")
        .toastViewStyle(IndefiniteProgressToastViewStyle())
    }
    .alert(isPresented: $showFailedAlert) {
      Alert(title: Text("Failed"),
            message: Text("Failed to register the account. Please try again later"))
    }
    .navigationTitle("Login")
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(linkActive: .constant(false))
  }
}
