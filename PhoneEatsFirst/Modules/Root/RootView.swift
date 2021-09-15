//
//  ContentView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import Resolver
import SwiftUI

struct RootView: View {
  @InjectedObject private var repository: DataRepository

  @State private var presentingSplashScreen: Bool = false

  var body: some View {
    ZStack {
      if repository.user == nil {
        LandingView().animation(.none)
      } else {
        MainView().animation(.none)
      }
    }
    .accentColor(.pink)
    .splashScreen(isPresented: $presentingSplashScreen)
    .animation(.easeInOut(duration: 1.0))
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
