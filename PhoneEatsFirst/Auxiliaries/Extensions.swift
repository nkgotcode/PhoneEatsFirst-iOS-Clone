//
//  Extensions.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/9/21.
//

import SwiftUI

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
    )
  }
}
