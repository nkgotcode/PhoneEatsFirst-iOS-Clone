//
//  MainView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/10/21.
//

import SwiftUI
import Resolver

class MainViewController: UITabBarController {
  @Injected private var repository: DataRepository

  override func viewDidLoad() {
    super.viewDidLoad()

    let addFriendButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "person.badge.plus"),
      style: .plain,
      target: self,
      action: #selector(presentAddFriendView)
    )
    let notificationButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "bell"),
      style: .plain,
      target: self,
      action: #selector(presentNotificationView)
    )

    let homeViewController = UIHostingController(rootView: HomeView())
    homeViewController.title = "Home"
    homeViewController.navigationItem.leftBarButtonItem = addFriendButtonItem
    homeViewController.navigationItem.rightBarButtonItem = notificationButtonItem
    homeViewController.tabBarItem = UITabBarItem(
      title: "Home",
      image: UIImage(systemName: "house.fill"),
      tag: 0
    )

    let discoverViewController = UIHostingController(rootView: DiscoverView())
    discoverViewController.title = "Discover"
    discoverViewController.navigationItem.leftBarButtonItem = addFriendButtonItem
    discoverViewController.navigationItem.rightBarButtonItem = notificationButtonItem
    discoverViewController.tabBarItem = UITabBarItem(
      title: "Discover",
      image: UIImage(systemName: "tag.fill"),
      tag: 1
    )

    let cameraViewController = CameraViewController()
    cameraViewController.tabBarItem = UITabBarItem(
      title: "Post",
      image: UIImage(systemName: "plus.diamond.fill"),
      tag: 2
    )

    let bookmarkViewController = UIHostingController(rootView: BookmarkView())
    bookmarkViewController.title = "Bookmark"
    bookmarkViewController.navigationItem.leftBarButtonItem = addFriendButtonItem
    bookmarkViewController.navigationItem.rightBarButtonItem = notificationButtonItem
    bookmarkViewController.tabBarItem = UITabBarItem(
      title: "Bookmark",
      image: UIImage(systemName: "bookmark.fill"),
      tag: 3
    )

    // TODO: force unwrap
    let profileViewController = UIHostingController(rootView: ProfileView(user: repository.user!))
    profileViewController.title = "Profile"
    profileViewController.navigationItem.leftBarButtonItem = addFriendButtonItem
    profileViewController.navigationItem.rightBarButtonItem = notificationButtonItem
    profileViewController.tabBarItem = UITabBarItem(
      title: "Profile",
      image: UIImage(systemName: "person.fill"),
      tag: 4
    )

    viewControllers = [
      UINavigationController(rootViewController: homeViewController),
      UINavigationController(rootViewController: discoverViewController),
      UINavigationController(rootViewController: cameraViewController),
      UINavigationController(rootViewController: bookmarkViewController),
      UINavigationController(rootViewController: profileViewController),
    ]
    
    self.tabBar.isTranslucent = false
    self.tabBar.overrideUserInterfaceStyle = .dark
    self.tabBar.inputViewController?.extendedLayoutIncludesOpaqueBars = true
  }

  @objc private func presentAddFriendView() {
    let viewController = UIHostingController(rootView: AddFriendView())
    present(viewController, animated: true, completion: nil)
  }

  @objc private func presentNotificationView() {
    let viewController = UIHostingController(rootView: NotificationView())
    present(viewController, animated: true, completion: nil)
  }
}

struct MainView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    MainViewController()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
  }
}

/* SwiftUI */
enum NavigationItem: Int {
  case home, discover, post, bookmark, profile
}

struct MainViewLegacy: View {
  @State private var uiTabBarController: UITabBarController?

  @State private var presentingAddFriendView: Bool = false
  @State private var presentingNotificationView: Bool = false

  @State private var previousSelection: NavigationItem = .discover
  @State private var selection: NavigationItem = .discover

  var body: some View {
    NavigationView {
      TabView(selection: $selection) {
        HomeView()
          .tabItem {
            Label("Home", systemImage: "house.fill")
          }
          .navigationTitle("Home")
          .tag(NavigationItem.home)

        DiscoverView()
          .tabItem {
            Label("Discover", systemImage: "tag.fill")
          }
          .navigationTitle("Discover")
          .tag(NavigationItem.discover)

//        PostView()
//          .tabItem {
//            Label("Post", systemImage: "plus.diamond.fill")
//          }
//          .navigationTitle("Post")
//          .tag(NavigationItem.post)

        BookmarkView()
          .tabItem {
            Label("Bookmark", systemImage: "bookmark.fill")
          }
          .navigationTitle("Bookmark")
          .tag(NavigationItem.bookmark)

//        ProfileView()
//          .tabItem {
//            Label("Profile", systemImage: "person.fill")
//          }
//          .navigationTitle("Profile")
//          .tag(NavigationItem.profile)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarContentView(presentingAddFriendView: $presentingAddFriendView,
                           presentingNotificationView: $presentingNotificationView)
      }
    }
    .navigationViewStyle(.stack)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
