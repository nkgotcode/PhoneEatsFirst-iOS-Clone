//
//  DiscoverFilterView.swift
//  DiscoverFilterView
//
//  Created by itsnk on 7/16/21.
//

import SwiftUI

struct DiscoverFilterView: View {
  @Environment(\.presentationMode) private var presentationMode

  var body: some View {
    NavigationView {
      Text("Filter View")
        .navigationTitle("Filter")
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

struct DiscoverFilterView_Previews: PreviewProvider {
  static var previews: some View {
    DiscoverFilterView()
  }
}
