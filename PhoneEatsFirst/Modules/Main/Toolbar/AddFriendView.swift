//
//  AddFriendView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/11/21.
//

import SwiftUI

struct AddFriendView: View {
  @Environment(\.presentationMode) private var presentationMode

  @State private var searchText: String = ""

  var body: some View {
    NavigationView {
      VStack {
        SearchBar("Search...", text: $searchText)
          .animation(.default)
        Spacer()
        Text("Add Friend View")
        Spacer()
      }
      .padding()
      .navigationTitle("Add Friend")
      .navigationViewStyle(.stack)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          Text("Done").bold()
        }
      }
    }
  }
}

struct AddFriendView_Previews: PreviewProvider {
  static var previews: some View {
    AddFriendView()
  }
}
