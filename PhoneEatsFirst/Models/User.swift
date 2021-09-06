//
//  User.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/11/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
  var id: String
  var username: String
  var firstName: String
  var lastName: String
  var email: String
  var bio: String?
  var gender: String?
  var country: String?
  var phone: String?
  var following: [String]
  var followers: [String]
  var userReviewsID: [String]
  var bookmarks: [String]
  var favoriteFoods: [Food]
  var profileImageUrl: String?
  @ServerTimestamp var creationDate: Timestamp?
  @ServerTimestamp var lastLoginDate: Timestamp?
}
