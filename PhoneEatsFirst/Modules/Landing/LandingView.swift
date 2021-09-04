//
//  LandingView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/10/21.
//

import SwiftUI

struct AnimatedBackground: View {
  @State private var index: Int = 0
  
  private let images = (1 ... 6).map { String(format: "landing%d", $0) }.map { Image($0) }
  private let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
  
  var body: some View {
    ZStack {
      ForEach(images.indices, id: \.self) { imageIndex in
        images[imageIndex]
          .resizable()
          .ignoresSafeArea()
          .scaledToFill()
          .scaleEffect(1.1)
          .animation(.none)
          .opacity(imageIndex == index ? 1 : 0)
          .animation(imageIndex == index ? .easeOut(duration: 1) : .easeIn(duration: 1))
      }
    }
    .blur(radius: 3.0)
    .onReceive(timer) { _ in
      withAnimation {
        index = index < images.count - 1 ? index + 1 : 0
      }
    }
    // TODO: disconnect timer
  }
}

struct LandingView: View {
  @State private var loginLinkActive: Bool = false
  @State private var registerLinkActive: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        HStack(alignment: .top) {
          //          Text("Discover the foodie in you!")
          Spacer()
          Image("logo")
            .resizable()
            .frame(width: 100, height: 100)
        }
        
        Spacer()
        
        NavigationLink(isActive: $loginLinkActive) {
          LoginView(linkActive: $loginLinkActive)
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
        .isDetailLink(false)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .hoverEffect(.highlight)
        
        NavigationLink(isActive: $registerLinkActive) {
          RegisterView(linkActive: $registerLinkActive)
        } label: {
          HStack(spacing: 4) {
            Text("New to PhoneEatsFirst?")
              .foregroundColor(.white)
            Text("Sign up").bold()
          }
        }
        .isDetailLink(false)
        .contentShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .hoverEffect(.highlight)
      }
      .padding()
      .background(AnimatedBackground().ignoresSafeArea())
      .navigationTitle("PhoneEatsFirst")
    }
    .navigationViewStyle(.stack)
  }
}

struct LandingView_Previews: PreviewProvider {
  static var previews: some View {
    LandingView()
  }
}
