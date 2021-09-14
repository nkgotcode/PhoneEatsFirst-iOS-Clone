//
//  Review.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/11/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum Rating: String, Codable {
  case bad = "Bad"
  case poor = "Poor"
  case fair = "Fair"
  case good = "Good"
  case excellent = "Excellent"
}

struct Review: Codable, Identifiable {
  @DocumentID var id: String?
  var description: String?
  var userId: String
  var businessId: String
  var imageUrl: String
  var foodRating: Double
  var serviceRating: Double
  var atmosphereRating: Double
  var valueRating: Double
  var rating: Double // based on ratings
  var tags: [String]
  var comments: [String]
  var likes: [String]
  var edited: Bool
  var additionalComment: String?
  @ServerTimestamp var creationDate: Timestamp?
  
  func initFromDocument(data: [String:Any]) -> Review {
    for dict in data {
      switch(dict.key) {
        case "id": self.id
        case "description": self.description
        case "userId": self.userId
        case "businessId": self.businessId
        case "imageUrl": self.imageUrl
        case "foodRating": self.foodRating
        case "serviceRating": self.serviceRating
        case "atmosphereRating": self.atmosphereRating
        case "valueRating": self.valueRating
        case "rating": self.rating
        case "tags": self.tags
        case "comments": self.comments
        case "likes": self.likes
        case "edited": self.edited
        case "additionalComment": self.additionalComment
        case "creationDate": self.creationDate
        default: return self
      }
    }
    return self
  }
}
