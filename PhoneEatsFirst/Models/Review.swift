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
}
