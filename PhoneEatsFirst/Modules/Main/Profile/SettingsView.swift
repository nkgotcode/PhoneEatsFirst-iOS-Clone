//
//  SettingsView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/13/21.
//

import Resolver
import SwiftUI

// https://stackoverflow.com/questions/59129890/implementing-a-tag-list-in-swiftui

struct SettingsView: View {
  @Injected var repository: DataRepository

  @Environment(\.presentationMode) private var presentationMode

  @State private var showLicensePage: Bool = false
  @State private var showPrivacyPolicyPage: Bool = false

  @StateObject private var webViewStore = WebViewStore()

  var body: some View {
    NavigationView {
      VStack {
        Spacer()

        VStack(spacing: 8) {
          Button {
            showLicensePage = true
          } label: {
            Text("Terms of Service").bold()
          }
          .sheet(isPresented: $showLicensePage) {
            WebWrapperView(
              webViewStore: webViewStore,
              title: "Terms of Service",
              url: "https://www.phoneeatsfirst.com/terms-of-service"
            )
          }

          Button {
            showPrivacyPolicyPage = true
          } label: {
            Text("Privacy Policy").bold()
          }
          .sheet(isPresented: $showPrivacyPolicyPage) {
            WebWrapperView(
              webViewStore: webViewStore,
              title: "Privacy Policy",
              url: "https://www.phoneeatsfirst.com/privacy-policy-4"
            )
          }
        }

        Button {
          do {
            try repository.logout()
            presentationMode.wrappedValue.dismiss()
          } catch {
            print("Failed to logout") // TODO: alert user
          }
        } label: {
          Text("Logout")
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
//      .navigationTitle("Settings")
//      .navigationBarTitleDisplayMode(.inline)
//      .toolbar {
//        Button {
//          presentationMode.wrappedValue.dismiss()
//        } label: {
//          Text("Done").bold()
//        }
//      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
