//
//  ActivityView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/26/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  
  var activityItems: [Any]
  
  var applicationActivities: [UIActivity]?
  var excludedActivityTypes: [UIActivity.ActivityType]?
  var onComplete: (((Result<(types: UIActivity.ActivityType, items: [Any]?), Error>)?) -> Void)?
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    .init(activityItems: activityItems, applicationActivities: applicationActivities)
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    uiViewController.excludedActivityTypes = excludedActivityTypes
    
    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      presentationMode.wrappedValue.dismiss()
      if let error = error {
        onComplete?(.failure(error))
      } else if let activity = activity, success {
        onComplete?(.success((activity, items)))
      } else if !success {
        onComplete?(nil)
      } else {
        assertionFailure()
      }
    }
  }
}
