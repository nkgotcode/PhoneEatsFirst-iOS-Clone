//
//  DiscoverView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import SwiftUI
import Resolver

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
//  @State var bookmarkViewModel: BookmarkViewModel
  @State var presentingFilterView = false
  @State var pickerSelection: ListMode = .list
  @State var filterListMode: FilterMode = .popular

  @State var searchText: String = ""
  
  var user: User

  var body: some View {
    VStack {
      VStack(spacing: 12) {
        HStack {
          SearchBar("Search...", text: $searchText)

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

//struct DiscoverView_Previews: PreviewProvider {
//  static var previews: some View {
//    Group {
//      DiscoverView()
//        .environmentObject(DataRepository())
//    }
//  }
//}
