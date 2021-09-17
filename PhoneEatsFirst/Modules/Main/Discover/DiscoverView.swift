//
//  DiscoverView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import SwiftUI
import Resolver
import SDWebImageSwiftUI

enum ListMode: Int {
  case list
  case map
}

enum FilterMode: String, CaseIterable, Identifiable {
  var id: FilterMode { self }

  case popular = "Most Popular"
  case rated = "Best Rated By Friends"
  case new = "New Around You"
}

struct DiscoverView: View {
  @Environment(\.presentationMode) private var presentationMode
  @Injected private var repository: DataRepository
  @State var presentingFilterView = false
  @State var pickerSelection: ListMode = .list
  @State var filterListMode: FilterMode = .popular
  @State var presentingProfileView = false
  @State var searchText: String = ""
  var user: User

  var body: some View {
    VStack {
      VStack(spacing: 12) {
        HStack {
          VStack {
            SearchBar("Search...", text: $searchText)
            
          }
          // filter button
          Button {
            presentingFilterView = true
          } label: {
            Image(systemName: "slider.horizontal.3")
              .resizable()
              .frame(width: 18, height: 18)
              .padding(10)
          }
          .sheet(isPresented: $presentingFilterView) {
            DiscoverFilterView()
          }
        }

        if searchText != "" {
          List(repository.users.filter({searchText.isEmpty ? true : $0.username.contains(searchText)})) {
            user in
            NavigationLink(destination: ProfileViewWrapper(user: user, profilePictureModel: ProfilePictureModel(user: user, profileImage: UIImage(), imgView: UIImageView()))) {
            HStack {
                HStack {
                  WebImage(url: URL(string: user.profileImageUrl!))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40, alignment: .center)
                  
                  Text(user.username).foregroundColor(Color.pink)
                }
            }
          }
          }
        }
        
        // filter bar below search bar
        HStack {
          Menu {
            ForEach(FilterMode.allCases) { mode in
              Button {
                filterListMode = mode
              } label: {
                Text(mode.rawValue)
              }
            }
          } label: {
            Label(filterListMode.rawValue, systemImage: "chevron.down")
          }
          .animation(.none)

          Spacer()

          Picker("Main", selection: $pickerSelection) {
            Image(systemName: "list.bullet").tag(ListMode.list)
            Image(systemName: "map").tag(ListMode.map)
          }
          .pickerStyle(SegmentedPickerStyle())
          .frame(width: 100)
        }
      }
      .padding(.horizontal)
      .padding(.top)

      // main content view
      PageView(selection: $pickerSelection, indexDisplayMode: .never) {
        DiscoverListView(user: user).tag(ListMode.list).animation(.none)
        MapView().tag(ListMode.map)
      }
      .ignoresSafeArea(.container, edges: .vertical)
    }
//    .navigationBarSearch($searchText)
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .animation(.default)
  }
}

struct Filter { let user: User; let business: Business }

extension Filter {
  
}

//class ProfileViewWrapper: UIViewControllerRepresentable {
//  typealias UIViewControllerType = ProfileViewController
//  var user: User?
//
//  func makeUIViewController(context: Context) -> ProfileViewController {
//    let profileVC = ProfileViewController()
//    profileVC.user = user
//    return profileVC
//  }
//
//  func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
//
//  }
//
//}
//struct DiscoverView_Previews: PreviewProvider {
//  static var previews: some View {
//    Group {
//      DiscoverView()
//        .environmentObject(DataRepository())
//    }
//  }
//}
