//
//  ReviewView.swift
//  ReviewView
//
//  Created by itsnk on 7/16/21.
//

import SwiftUI
import Resolver
import FirebaseStorage
import SDWebImageSwiftUI
import Foundation

struct ReviewView: View {
  let review: Review
  let tags: [ReviewTag]

  var dismissAction: (() -> Void)
  
  @Injected private var repository: DataRepository
  
  @State private var bookmarked: Bool = false
  @State private var liked: Bool = false
  @State private var presentingProfileView: Bool = false
  
  var body: some View {
    let user = repository.getUser(id: review.userId)
    let business = repository.getBusiness(id: review.businessId)
    let displayTime = repository.getDisplayTimestamp(creationDate: review.creationDate!)
    
//    ScrollView {
//    NavigationView {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Button {
//            presentingProfileView = true
          }label: {
            NavigationLink(destination: ProfileViewWrapper(user: user!), label: {
              Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
      
              Text(user!.username)
                .font(.headline)
                .foregroundColor(Color.pink)
            })

          }
//          .sheet(isPresented: $presentingProfileView) {
//            // TODO: force unwrap?
//            ProfileView(user: repository.getUser(id: review.userId)!).accentColor(Color.pink)
//          }
          
          Spacer()
            
          Menu {
            Button {
              // delete
            } label: {
              Label("Delete", systemImage: "trash")
            }
            Button {
              // report
            } label: {
              Label("Report", systemImage: "flag")
            }
          } label: {
            Image(systemName: "line.horizontal.3")
              .resizable()
              .frame(width: 14, height: 14)
              .accentColor(Color.pink)
          }
        }
        .padding(.vertical, 8)
          
        // for restaurant name, location, and review stars
        HStack {

          Text(business!.name)
            .font(.caption)
            .italic()
          //            .frame(maxWidth: .infinity, alignment: .leading)
            
          if let price = business?.price {
            Text(String(repeating: "$", count: price))
              .font(.footnote)
           }
            
          Spacer()
          if let stars = business?.stars {
            let tmp = repository.getTruncatedRatings(ratings: stars)
            Label(String(format: "%f", stars), systemImage: "star.fill")
              .font(.footnote)
              .foregroundColor(Color(.systemPink))
          }
          //          }
            
          Spacer()
            
          Text(business!.address)
            .font(.caption)
            .italic()
            .lineLimit(1)
        }
          
        let pinImage = Image(systemName: "pin.circle.fill")
          .font(.title2)
          .foregroundColor(Color.pink)
          .padding(.vertical, 16)
          .padding(.horizontal, 8)
          
        // review image
        ZStack {
          WebImage(url: URL(string: review.imageUrl))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(20.0)
            .padding(.vertical, 8)
            .overlay(pinImage, alignment: .bottomLeading)
            .padding(.horizontal, -8)
          
        }
        // interactions bar
        HStack(spacing: 12) {
          // like button
          Button {
            liked.toggle()
          } label: {
            Image(systemName: liked ? "heart.fill" : "heart")
              .font(.title2)
              .accentColor(Color(.systemPink))
          }
          
          // comment button
          NavigationLink {
            CommentView(review: review)
          } label: {
            Image(systemName: "bubble.right")
              .font(.title2)
              .accentColor(Color.pink)
          }
            
          Spacer()
            
          // bookmark button
          Button {
            bookmarked.toggle()
          } label: {
            Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
              .font(.title2)
              .accentColor(Color(.systemPink))
          }
        }
        .padding(.vertical, 4)
          
        // review's comment
        Group {
          Text(user!.username).font(.footnote).bold()
            + Text(" ")
            + Text(review.additionalComment!).font(.footnote)
        }
          
        // review's timestamp
        Text(displayTime)
          .font(.caption2.weight(.light))
          .padding(.vertical, 4)
        
        
        Spacer()
      }
      .padding(.horizontal, 8)
//      .padding(.vertical, 8)
//    } // ScrollView
//      .navigationTitle("Review")
//    .navigationBarTitleDisplayMode(.inline)
//    .toolbar {
//      Button(action: dismissAction, label: {
//        Text("Done").bold()
//      })
//    }
//    .accentColor(Color.pink)
//  }
  }
}

struct ProfileViewWrapper: UIViewControllerRepresentable {
  typealias UIViewControllerType = ProfileViewController
  var user: User
  
  func makeUIViewController(context: Context) -> ProfileViewController {
    let profile = ProfileViewController()
    profile.user = self.user
    
    return profile
  }
  
  func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
    
  }
  
}
