//
//  Comment.swift
//  Comment
//
//  Created by itsnk on 9/5/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Comment: Codable, Identifiable {
  @DocumentID var id: String?
  var comment: String
  var uid: String
  @ServerTimestamp var creationDate: Timestamp?
}
