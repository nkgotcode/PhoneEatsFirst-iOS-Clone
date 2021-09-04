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

struct ReviewView: View {
  let review: Review

  @Environment(\.presentationMode) private var presentationMode
  
  @Injected private var repository: DataRepository
  
  @State private var bookmarked: Bool = false
  @State private var liked: Bool = false
  @State private var presentingProfileView: Bool = false
  
  var body: some View {
    let user = repository.getUser(id: review.userId)
    let business = repository.getBusiness(id: review.businessId)
    
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Button {
            presentingProfileView = true
          }label: {
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .frame(width: 20, height: 20)
    
            Text(user!.username)
              .font(.headline)
              .foregroundColor(Color.pink)
          }.sheet(isPresented: $presentingProfileView) {
            // TODO: force unwrap?
            ProfileView(user: repository.getUser(id: review.userId)!).accentColor(Color.pink)
          }
          
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

            Label(String(format: "%f", stars.truncate(places: 2)), systemImage: "star.fill")
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
        WebImage(url: URL(string: review.imageUrl))
          .resizable()
          .aspectRatio(contentMode: .fit)
          .cornerRadius(20.0)
          .padding(.vertical, 8)
          .overlay(pinImage, alignment: .bottomLeading)
          .padding(.horizontal, -8)
          
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
            CommentView()
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
//        let timestamp = Date(timeIntervalSince1970: review.creationDate?.seconds)
//        let now = Date().offsetFrom(date: timestamp)
        
//        Text(now)
        Text("5 days ago")
          .font(.caption2.weight(.light))
          .padding(.vertical, 4)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    } // ScrollView
    .navigationTitle("Review")
    .navigationBarTitleDisplayMode(.inline)
    .accentColor(Color.pink)
  }
}

extension Double
{
  func truncate(places : Int)-> Double
  {
      return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
  }
}

extension Date {

  func offsetFrom(date: Date) -> String {

      let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
      let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)

      let seconds = "\(difference.second ?? 0)s"
      let minutes = "\(difference.minute ?? 0)m" + " " + seconds
      let hours = "\(difference.hour ?? 0)h" + " " + minutes
      let days = "\(difference.day ?? 0)d" + " " + hours

      if let day = difference.day, day          > 0 { return days }
      if let hour = difference.hour, hour       > 0 { return hours }
      if let minute = difference.minute, minute > 0 { return minutes }
      if let second = difference.second, second > 0 { return seconds }
      return ""
  }

}
