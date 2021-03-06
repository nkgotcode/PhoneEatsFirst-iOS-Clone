//
//  DiscoverListView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/9/21.
//

import Resolver
import SDWebImageSwiftUI
import SwiftUI

struct DiscoverListView: View {
  @Environment(\.presentationMode) private var presentationMode
  @Injected private var repository: DataRepository
//  @ObservedObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
  @State private var chosenBusiness: Business? = nil
  @State private var presentingBusinessView: Bool = false
//  @State var isBookmarked: Bool!
  var user: User

  var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
        ForEach(repository.businesses) { business in
          GeometryReader { geo in
            Button {
              chosenBusiness = business
            } label: {
              ZStack(alignment: .top) {
                // background
                if let imageUrl = business.imageUrl {
                  WebImage(url: URL(string: imageUrl)!)
                    .resizable()
                    .placeholder(Image("placeholder"))
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .cornerRadius(20)
                    .frame(height: geo.size.height)
                    .aspectRatio(contentMode: .fill)
                    .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                } else {
                  Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                }

                // label
                VStack(alignment: .leading) {
                  Text(business.name)
                    .bold()
                    .font(.title3)

                  let addr = business.address + ", " + business.city + ", "
                    + business.state + " " + business.zipcode
                  Text(addr)
                    .font(.footnote)

                  Spacer()

                  HStack(spacing: 16) {
                    if let stars = business.stars {
                      Label(String(format: "%.1f", stars), systemImage: "star.fill")
                        .font(.footnote)
                        .foregroundColor(Color(.systemPink))
                    }

                    if let price = business.price {
                      Text(String(repeating: "$", count: price))
                        .font(.footnote)
                    }

                    Spacer()

  //                  Button {
  //                    chosenBusiness = business
  //                  } label: {
  //                    Image(systemName: "square.and.arrow.up")
  //                  }

//                    Button {
//                      // bookmark
////                      if bookmarkViewModel.bookmarked.contains(business.id) {
////                        bookmarkViewModel.bookmarked.removeAll(where: {$0 == business.id})
////                      } else {
////                        bookmarkViewModel.bookmarked.append(business.id)
////                      }
////                      bookmarked.toggle()
//                      bookmarkViewModel.clickedBtn(businessID: business.id!)
//                      print("user bookmarked \(String(describing: business.id))")
//                    } label: {
////                      if let result = bookmarkViewModel.bookmarkDict[business.id] {
////                        Image(result ? "bookmark.fill" : "bookmark")
////                      }
////                      if repository.isBookmarked(business: business) {
////                        Image(systemName: "bookmark.fill")
////                      } else {
////                        Image(systemName: "bookmark")
////                      }
//                      Image(systemName: "bookmark")
////                      Image(systemName: repository.isBookmarked(business: business) ? "bookmark.fill" : "bookmark")
////                      if bookmarkViewModel.bookmarked.contains(business.id) {
////                        Image(systemName: "bookmark.fill")
////                      } else {
////                        Image(systemName: "bookmark")
////                      }
//                    }
                  }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                  RoundedRectangle(cornerRadius: 10.0)
                    .foregroundColor(Color(.secondarySystemBackground))
                )
                .frame(maxHeight: 90)
                .padding(12)
              } // ZStack
            } // Button
          } // geo reader
          .clipped()
          .aspectRatio(contentMode: .fit)
          .cornerRadius(20)
        } // ForEach
        .padding()
        .sheet(item: $chosenBusiness) { business in
          BusinessView(business: business).accentColor(.pink)
        }
      } // LazyVGrid
      .toolbar {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          Text("Done").bold()
        }
      }
    } // ScrollView
  }
}
