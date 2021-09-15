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
  let user: User
  @ObservedObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
  @State var presentingBusinessView: Bool = false
  @State var bookmarked: Bool = false
  
  var body: some View {
    ScrollView {
      // TODO: user should not be nil else show nothing?
      ForEach(bookmarkViewModel.bookmarked.reversed(), id: \.self) { businessID in
        let business = repository.getBusiness(id: businessID)
        VStack {
          // each bookmark is a button
          Button {
            presentingBusinessView = true
          } label: {
            if let imageUrl = business?.imageUrl {
              WebImage(url: URL(string: imageUrl)!)
                .placeholder(Image("placeholder"))
                .centerSquareCropped()
                .transition(.fade(duration: 0.5))
                .frame(width: 80, height: 80)
                .cornerRadius(4)
            } else {
              Image("placeholder")
                .centerSquareCropped()
                .frame(width: 80, height: 80)
                .cornerRadius(4)
            }

            VStack (alignment: .leading) {
              Text(business!.name).bold()
              
              HStack (spacing: 8) {
                if let price = business?.price {
                  Text(String(repeating: "$", count: price))
                    .font(.footnote)
                }
                
                if let stars = business?.stars {
                  Label(String(format: "%.2f", stars), systemImage: "star.fill")
                    .font(.footnote)
                    .foregroundColor(Color(.systemPink))
                }
              }.padding(.top, 4)
            }.padding(.leading, 4)

            Spacer()

            // bookmark button
            // TODO: check user bookmark
            Button {
              bookmarkViewModel.clickedBtn(businessID: businessID)
            } label: {
              Image(systemName: bookmarkViewModel.checkBookmark(businessID: businessID) ? "bookmark.fill" : "bookmark")
                .font(.title2)
                .accentColor(Color(.systemPink))
            }
          }
          .sheet(isPresented: $presentingBusinessView) {
            BusinessView(business: business!).accentColor(.pink)
          }

          Divider()
        } // VStack
      } // ForEach
      .padding()
    } // ScrollView
  }

}
