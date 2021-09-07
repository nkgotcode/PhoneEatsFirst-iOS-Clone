//
//  ReviewTag.swift
//  ReviewTag
//
//  Created by itsnk on 9/5/21.
//

import Foundation
import FirebaseFirestoreSwift

struct ReviewTag: Codable, Identifiable {
  @DocumentID var id: String?
  var x: Double
  var y: Double
  var description: String
}
