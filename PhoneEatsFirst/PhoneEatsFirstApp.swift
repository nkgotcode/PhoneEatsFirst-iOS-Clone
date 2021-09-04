//
//  PhoneEatsFirstApp.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import IQKeyboardManagerSwift
import Firebase
import Resolver
import SwiftUI

@main
struct PhoneEatsFirstApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      RootView().ignoresSafeArea()
    }
  }
}

//struct ContentViewNameSpace: View {
//    @State private var isExpanded = false
//    @Namespace private var namespace
//
//
//    var body: some View {
//        Group() {
//        if isExpanded {
//            VerticalView(namespace: namespace)
//        } else {
//            HorizontalView(namespace: namespace)
//        }
//        }.onTapGesture {
//        withAnimation {
//            isExpanded.toggle()
//        }
//        }
//    }
//}
//struct VerticalView: View {
//    var namespace: Namespace.ID
//
//    var body: some View {
//        VStack {
//        RoundedRectangle(cornerRadius: 10)
//            .foregroundColor(Color.pink)
//            .frame(width: 60, height: 60)
//            .matchedGeometryEffect(id: "rect", in: namespace, properties: .frame)
//        Text("Hello SwiftUI!").fontWeight(.semibold)
//            .matchedGeometryEffect(id: "text", in: namespace)
//        }
//    }
//}
//struct HorizontalView: View {
//    var namespace: Namespace.ID
//
//    var body: some View {
//        HStack {
//        Text("Hello SwiftUI!").fontWeight(.semibold)
//            .matchedGeometryEffect(id: "text", in: namespace)
//        RoundedRectangle(cornerRadius: 10)
//            .foregroundColor(Color.pink)
//            .frame(width: 60, height: 60)
//            .matchedGeometryEffect(id: "rect", in: namespace, properties: .frame)
//        }
//    }
//}

class AppDelegate: UIResponder, UIApplicationDelegate {
  static var orientationLock: UIInterfaceOrientationMask = .all

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true

    return true
  }

  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    AppDelegate.orientationLock
  }
}

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { DataRepository() }.scope(.application)
  }
}

