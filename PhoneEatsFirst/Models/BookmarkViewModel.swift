//
//  BookmarkViewModel.swift
//  BookmarkViewModel
//
//  Created by itsnk on 9/14/21.
//

import Foundation
import SwiftUI
import Resolver

class BookmarkViewModel: ObservableObject {
  @Injected private var repository: DataRepository
  @Published var bookmarked = [String]()
  @Published var bookmarkDict = [Business:Bool]()
  @State var currBtnEnabled: Bool?
  
  init() {
    load()
  }

  func load() {
    bookmarked.append(contentsOf: repository.user!.bookmarks)
    for business in repository.businesses {
      if bookmarked.contains(business.id!) {
        bookmarkDict[business] = true
      } else {
        bookmarkDict[business] = false
      }
    }
  }
  
  func clickedBtn(businessID: String) {
    let result = checkBookmark(businessID: businessID)
    let business = repository.getBusiness(id: businessID)
    if result {
      repository.deleteUserBookmark(business: repository.getBusiness(id: businessID)!)
      bookmarked.removeAll(where: {$0 == businessID})
      bookmarkDict[business!] = false
    } else {
      repository.addUserBookmark(business: repository.getBusiness(id: businessID)!)
      bookmarked.append(businessID)
      bookmarkDict[business!] = true
    }
  }
  
  func checkBookmark(businessID: String) -> Bool {
    if bookmarked.contains(businessID) {
      return true
    } else {
      return false
    }
  }
}
