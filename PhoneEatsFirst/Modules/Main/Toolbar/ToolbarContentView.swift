//
//  ToolbarContentView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import SwiftUI

/* SwiftUI */
struct ToolbarContentView: ToolbarContent {
  @Binding var presentingAddFriendView: Bool
  @Binding var presentingNotificationView: Bool

  var body: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      if #available(iOS 15.0, *) {
        Image("logo")
          .resizable()
          .scaledToFit()
      } else {
        Image("logo")
          .resizable()
          .scaleEffect(0.13)
      }
    }

    ToolbarItem(placement: .navigationBarLeading) {
      Button {
        presentingAddFriendView = true
      } label: {
        Image(systemName: "person.badge.plus")
      }
      .sheet(isPresented: $presentingAddFriendView) {
        AddFriendView().accentColor(.pink)
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        presentingNotificationView = true
      } label: {
        Image(systemName: "bell")
      }
      .sheet(isPresented: $presentingNotificationView) {
        NotificationView().accentColor(.pink)
      }
    }
  }
}
