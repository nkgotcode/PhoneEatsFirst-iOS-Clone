//
//  WebWrapperView.swift
//  WebWrapperView
//
//  Created by itsnk on 7/26/21.
//

import SwiftUI

struct WebWrapperView: View {
  @Environment(\.presentationMode) private var presentationMode

  @ObservedObject var webViewStore: WebViewStore
  
  var title: String
  var url: String

  var body: some View {
    NavigationView {
      WebView(webView: webViewStore.webView)
        .onAppear {
          let url = URL(string: url)!
          if webViewStore.webView.url != url {
            webViewStore.webView.load(URLRequest(url: url))
          }
        }
        .navigationTitle(title)
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
