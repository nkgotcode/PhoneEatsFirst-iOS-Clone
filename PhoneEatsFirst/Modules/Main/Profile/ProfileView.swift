//
//  ProfileView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/4/21.
//

import Resolver
import SDWebImageSwiftUI
import SwiftUI

struct ProfileView: View {
  let user: User

  @Injected var repository: DataRepository

  @State var presentingSettingsView: Bool = false
  @State var presentingEditProfileView: Bool = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading) {
        HStack {
          // avatar
          if let imageUrl = user.profileImageUrl {
            WebImage(url: URL(string: imageUrl)!)
              .resizable()
              .placeholder(Image(systemName: "person.crop.circle.fill"))
              .transition(.fade(duration: 0.5))
              .scaledToFit()
              .frame(width: 70, height: 70)
              .cornerRadius(35)
          } else {
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .frame(width: 70, height: 70)
              .cornerRadius(35)
          }

          Spacer()

          HStack {
            NavigationLink(destination: FollowerView()) {
              VStack {
                Text(String(user.followers.count)).bold()
                Text("Followers")
              }
            }

            NavigationLink(destination: FollowingView()) {
              VStack {
                Text(String(user.following.count)).bold()
                Text("Following")
              }
            }
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
        
        // username
        VStack(alignment: .leading) {
          Text("@" + user.username).font(Font.system(size: 14)).foregroundColor(Color.gray)
          if let bio = user.bio {
            Text(bio)
          }
        }.padding(.leading, 15)

        // bio
        VStack(alignment: .leading) {
          Text(user.firstName + " " + user.lastName).bold()
          if let bio = user.bio {
            Text(bio)
          }
        }.padding(.leading, 15)

        // buttons
        VStack(spacing: 8) {
          HStack {
            // edit profile button
            Button {
              presentingEditProfileView = true
            } label: {
              Text("Edit Profile")
                .font(.footnote.bold())
                .padding(.vertical, 10)
                .foregroundColor(Color(.label))
                .frame(maxWidth: .infinity)
                .overlay(
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .sheet(isPresented: $presentingEditProfileView) {
              EditProfileView().accentColor(.pink)
            }

            // settings button
            Button {
              presentingSettingsView = true
            } label: {
              Text("Settings")
                .font(.footnote.bold())
                .padding(.vertical, 10)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .overlay(
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .sheet(isPresented: $presentingSettingsView) {
              SettingsView().accentColor(.pink)
            }
          }
          .padding(.horizontal)
        }

        // main review view
//        VStack (alignment: .leading){
//          ForEach(user.userReviewsID.reversed(), id: \.self) { reviewID in
//            if reviewID == nil {
//              Text("")
//            } else {
//              let review = repository.getReview(id: reviewID)
//              ReviewView(review: review!)
//            }
//          }
//        }
      }
//      .padding()
      .padding(.vertical)
    } // VStack
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  } // ScrollView
}

struct FollowerView: View {
  var body: some View {
    Text("Follower View")
  }
}

struct FollowingView: View {
  var body: some View {
    Text("Following View")
  }
}
