//
//  NotificationView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/11/21.
//

import SwiftUI

struct NotificationView: View {
  @Environment(\.presentationMode) private var presentationMode

  var body: some View {
    NavigationView {
      Text("Nothing to do here")
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
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

struct NotificationView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationView()
  }
}
