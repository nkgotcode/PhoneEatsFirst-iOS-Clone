//
//  BookmarkView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import Resolver
import SDWebImageSwiftUI
import SwiftUI

struct BookmarkView: View {
  @InjectedObject private var repository: DataRepository

  @State var presentingBusinessView: Bool = false
  @State var bookmarked: Bool = false

  var body: some View {
    ScrollView {
      // TODO: user should not be nil else show nothing?
      ForEach(repository.user!.bookmarks) { business in
        VStack {
          // each bookmark is a button
          Button {
            presentingBusinessView = true
          } label: {
            if let imageUrl = business.imageUrl {
              WebImage(url: URL(string: imageUrl)!)
                .resizable()
                .placeholder(Image("placeholder"))
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(4)
            } else {
              Image("placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(4)
            }

            Text(business.name)

            if let stars = business.stars {
              Label(String(format: "%d", stars), systemImage: "star.fill")
                .font(.footnote)
                .foregroundColor(Color(.systemPink))
            }

            Spacer()

            if let price = business.price {
              Text(String(repeating: "$", count: price))
                .font(.footnote)
            }

            Spacer()

            // bookmark button
            // TODO: check user bookmark
            Button {
              bookmarked.toggle()
            } label: {
              Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                .font(.title2)
                .accentColor(Color(.systemPink))
            }
          }
          .sheet(isPresented: $presentingBusinessView) {
            BusinessView(business: business).accentColor(.pink)
          }

          Divider()
        } // VStack
      } // ForEach
      .padding()
    } // ScrollView
  }
}
