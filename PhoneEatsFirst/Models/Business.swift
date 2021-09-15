//
//  Business.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/11/21.
//

import Foundation
import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

enum Weekday: Int, Codable {
  case Sun = 1
  case Mon = 2
  case Tue = 3
  case Wed = 4
  case Thu = 5
  case Fri = 6
  case Sat = 7
}

struct Business: Codable, Identifiable, Hashable {
  static func == (lhs: Business, rhs: Business) -> Bool {
    return lhs.id == rhs.id
  }
  func hash(into hasher: inout Hasher) {
      hasher.combine(id)
  }
  
  @DocumentID var id: String?
  var name: String
  var address: String
  var city: String
  var state: String
  var zipcode: String
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var open: Bool
  var stars: Double?
  var price: Int?
  var phone: String?
  var website: String?
  var imageUrl: String?
  var openingHours: [Weekday: Int] // store as minutes
  var closingHours: [Weekday: Int] // store as minutes
  var foods: [Food]
  var cuisines: [Cuisine]
  var reviews: [String]
}
