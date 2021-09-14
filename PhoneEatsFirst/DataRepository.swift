//
//  DataRepository.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/9/21.
//

import Combine
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import MapKit
import os
import SwiftUI
import SDWebImage

final class DataRepository: ObservableObject {
  @Published var users: [User] = []
  @Published var businesses: [Business] = []
  @Published var reviews: [Review] = []
  @Published var comments: [Comment] = []

  @Published private var firebaseUser: FirebaseAuth.User? = nil
  @Published var user: User? = nil

  let logger = Logger(subsystem: "com.itsnk.PhoneEatsFirst", category: "Repository")

  private let auth = Auth.auth()
  let firestore = Firestore.firestore()
  let storage = Storage.storage()

//  let storageRef = storage.reference()
//  let postImageRef = storageRef.child("postImages")
//  let profileImageRef = storageRef.child("profileImages")

  let businessPath = "businesses"
  let cuisinePath = "cuisines"
  let foodPath = "foods"
  let reviewPath = "reviews"
  let userPath = "users"
  let reviewTagPath = "reviewTags"
  let commentPath = "comments"

  private var authHandle: AuthStateDidChangeListenerHandle!

  private var cancellables: Set<AnyCancellable> = []

  init() {
//    mockDb()

    // authentication observer
    authHandle = auth.addStateDidChangeListener { _, user in
      self.firebaseUser = user
      // TODO: synchronize firestore user information and user authentication
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.user = self.getUser(id: user?.uid ?? "")
      }
    }

    // firestore observer
    firestore.collection(userPath).publisher(as: User.self)
      .replaceError(with: [])
      .assign(to: \.users, on: self)
      .store(in: &cancellables)

    firestore.collection(businessPath).publisher(as: Business.self)
      .replaceError(with: [])
      .assign(to: \.businesses, on: self)
      .store(in: &cancellables)

    firestore.collection(reviewPath).publisher(as: Review.self)
      .replaceError(with: [])
      .assign(to: \.reviews, on: self)
      .store(in: &cancellables)
  }

  deinit {
    auth.removeStateDidChangeListener(authHandle)
  }

  func getUser(id: String) -> User? {
    users.first(where: { $0.id == id })
  }

  func getBusiness(id: String) -> Business? {
    businesses.first(where: { $0.id == id })
  }
  
  func getTotalBusinessCount() -> Int {
    businesses.count
  }
  
  func getReview(id: String) -> Review? {
    reviews.first(where: { $0.id == id })
  }
  
  func getReviews(idArr: [String]) -> [Review] {
    var ret: [Review] = []
    for id in idArr {
      let r = getReview(id: id)
      ret.append(r!)
    }
    return ret
  }
  
  func getComments(reviewID: String) -> [Comment] {
    var ret: [Comment] = []
    
    firestore.collection(reviewPath).document(reviewID).collection(commentPath).getDocuments(completion: {
      querrySnapshot, err in
      if let err = err {
        print("Error getting documents: \(err)")
      }
      else {
        print("got documents")
        // for loop getting each comment
        for doc in querrySnapshot!.documents {
          let data = doc.data()
          print(data)
          var comment: String = ""
          var uid: String = ""
          var creationDate: Timestamp?
          
          for d in data {
            switch(d.key) {
              case "comment": comment = d.value as! String
              case "uid": uid = d.value as! String
              case "creationDate": creationDate = d.value as? Timestamp
              default: return
            }
            print (comment)
            print(uid)
            print(creationDate)
            let c = Comment(id: doc.documentID, comment: comment, uid: uid, creationDate: creationDate)
            print("got comment")
            ret.append(c)
          }
        }
      }
    })
    return ret
  }
  
  func getFollowingReviews(following: [String]) -> [String] {
    var ret: [String] = []
    for id in following {
      let u = getUser(id: id)
      ret.append(contentsOf: u!.userReviewsID)
    }
    return ret
  }
  
  func getDisplayTimestamp(creationDate: Timestamp) -> String {
    let postDate = Date(timeIntervalSince1970: TimeInterval(creationDate.seconds))
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    let ret = formatter.localizedString(for: postDate, relativeTo: Date())
    return ret
  }
  
  func getTagObjects(reviewID: String) -> [ReviewTag] {
    var tagObjects : [ReviewTag] = []
    firestore.collection(reviewPath).document(reviewID).collection(reviewTagPath).getDocuments(completion: {
      querrySnapshot, err in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        // for loop getting each review tag
        for doc in querrySnapshot!.documents {
          
          let data = doc.data()
          var x: Double = 0.0
          var y: Double = 0.0
          var description: String?
          // getting fields of review document
          for d in data {
            switch(d.key) {
            case "x": x = d.value as! Double
            case "y": y = d.value as! Double
            case "description": description = d.value as? String
            default: return
            }
            if description == nil {
              let tag = ReviewTag(id: doc.documentID, x: x, y: y, description: "")
              tagObjects.append(tag)
            } else {
              // create tag object and append to return array
              let tag = ReviewTag(id: doc.documentID, x: x, y: y, description: description!)
              tagObjects.append(tag)
            }
          }
        }
      }
    })
    return tagObjects
  }

  func login(email: String, password: String, completion: ((Bool) -> Void)? = nil) {
    auth.signIn(withEmail: email, password: password) { [weak self] result, error in
      guard let self = self else { return }
      if let error = error {
        self.logger.info("[Authentication] Login failed: \(error.localizedDescription)")
        completion?(false)
        return
      }
      guard let result = result else {
        self.logger.info("[Authentication] Login result is nil")
        completion?(false)
        return
      }

      self.user = self.getUser(id: result.user.uid)

      completion?(true)
    }
  }

  func logout() throws {
    try auth.signOut()
  }
  
  func downloadImage(imageRef: StorageReference, reviewID: String) -> UIImage {
    
    var img = UIImage()
    imageRef.child("\(reviewID)").getData(maxSize: 1500*1500) { data,error in
      if error != nil {
        print(error?.localizedDescription)
      } else {
        img = UIImage(data: data!)!
      }
    }
    return img
  }

  func uploadPost(image: UIImage, description: String?, businessId: String, foodRating: Double, serviceRating: Double, atmosphereRating: Double, valueRating: Double, tags: [String], tagObjects: [ReviewTag], additionalComment: String?) {
    var picURL: URL?
    let storageRef = storage.reference()
    let postId = firestore.collection(reviewPath).document().documentID
    guard let uid = user?.id else { return }
    guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 1000, height: 1000), scaleMode: .aspectFit) else {return}
    let picRef = storageRef.child("\(uid)/ori/\(postId).jpg")
//    let picRef = storage.reference(withPath: "\(uid)/ori/\(postId)")
//    let resizedPicRef = storage.reference(withPath: "\(uid)/resized/\(postId)")
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    // upload image to storage
    let uploadTask = storageRef.child("\(uid)/ori/\(postId).jpg").putData(resizedImage.pngData()!, metadata: metadata) { fullmetadata, err in
      if err != nil {
        print("Error uploading image")
        return
      }
    }
    
    // get url after done uploading
    uploadTask.observe(.success) { snapshot in
      snapshot.reference.downloadURL { url, error in
        if error != nil {
          print(error?.localizedDescription)
        }
        else {
          print(url)
          self.firestore.collection(self.reviewPath).document(postId).updateData([
            "imageUrl": url?.absoluteString])
          picURL = url
        }
      }
    }

      let url = ""
      let totalRatings = (foodRating + serviceRating + atmosphereRating + valueRating) / 4
      
      // uploading the review object to firestore
      let review = Review(
        id: postId, description: description, userId: uid, businessId: businessId, imageUrl: url, foodRating: foodRating, serviceRating: serviceRating, atmosphereRating: atmosphereRating, valueRating: valueRating, rating: totalRatings, tags: tags, comments: [], likes: [], edited: false, additionalComment: additionalComment, creationDate: nil)
      
      _ = self.firestore.collection(self.reviewPath).document(postId).setData(from: review)

      // append reviewID to user object
      var userReviewsID = self.user?.userReviewsID
      userReviewsID?.append(postId)
      self.firestore.collection(userPath).document(uid).updateData([
        "userReviewsID": userReviewsID!])
    
      // uploading tag objects for the image to firestore
      if tagObjects.count <= 0 {
        _ = self.firestore.collection(self.reviewPath).document(postId).collection(self.reviewTagPath)
      } else {
        for tag in tagObjects {
          _ = self.firestore.collection(self.reviewPath).document(postId).collection(self.reviewTagPath).document(tag.id!).setData(from: tag)
        }
      }
      // populate local version
    self.reviews.append(review)
  }

  func register(
    username: String,
    firstName: String,
    lastName: String,
    email: String,
    bio: String? = nil,
    gender: String? = nil,
    country: String? = nil,
    phone: String? = nil,
    password: String,
    completion: ((Bool) -> Void)? = nil
  ) {
    // TODO: verify user email
    auth.createUser(withEmail: email, password: password) { [weak self] result, error in
      guard let self = self else { return }
      if let error = error {
        self.logger.info("[Authentication] Register failed: \(error.localizedDescription)")
        completion?(false)
        return
      }
      guard let result = result else {
        self.logger.info("[Authentication] Register result is nil")
        completion?(false)
        return
      }

      let user = User(
        id: result.user.uid,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        bio: bio,
        gender: gender,
        country: country,
        phone: phone,
        following: [],
        followers: [],
        userReviewsID: [],
        bookmarks: [],
        favoriteFoods: [],
        profileImageUrl: "",
        creationDate: nil,
        lastLoginDate: nil
      )
      _ = self.firestore.collection(self.userPath)
        .document(result.user.uid)
        .setData(from: user)

      self.users.append(user)
      completion?(true)
    }
  }
  
  func followUser(id: String) {
    var followingUser = getUser(id: id)
    followingUser?.followers.append(user!.id)
    firestore.collection(userPath).document(id).updateData(["followers": followingUser?.followers])
    user?.following.append(followingUser!.id)
    firestore.collection(userPath).document(user!.id).updateData(["following": user?.following])
  }
  
  func unfollowUser(id: String) {
    var unfollowingUser = getUser(id: id)
    unfollowingUser?.followers.removeAll(where: {$0 == user?.id})
    firestore.collection(userPath).document(id).updateData(["followers": unfollowingUser?.followers])
    user?.following.removeAll(where: {$0 == unfollowingUser!.id})
    firestore.collection(userPath).document(user!.id).updateData(["following": user?.following])
  }
  
  func likeReview(reviewID: String, uid: String) {
    var review = getReview(id: reviewID)
    review?.likes.append(uid)
    firestore.collection(reviewPath).document(reviewID).updateData(["likes": review?.likes])
  }
  
  func unlikeReview(reviewID: String, uid: String) {
    var review = getReview(id: reviewID)
    review?.likes.removeAll(where: {$0 == uid})
    firestore.collection(reviewPath).document(reviewID).updateData(["likes": review?.likes])
  }
  
  func bookmarkBusiness(businessID: String) {
    user?.bookmarks.append(businessID)
    firestore.collection(userPath).document(user!.id).updateData(["bookmarks": user?.bookmarks])
  }
  
  func unbookmarkBusiness(businessID: String) {
    user?.bookmarks.removeAll(where: {$0 == businessID})
    firestore.collection(userPath).document(user!.id).updateData(["bookmarks": user?.bookmarks])
  }
  
  func uploadComment(comment: Comment, review: Review, commentIDs: [String]) {
    self.comments.append(comment)
    var upload = firestore.collection(self.reviewPath).document(review.id!).collection(commentPath).document(comment.id!).setData(from: comment)

    firestore.collection(reviewPath).document(review.id!).updateData(["comments": review.comments])
  }
  
  func uploadProfilePicture(image: UIImage) {
    var picURL: URL?
    let storageRef = storage.reference()
    guard let uid = user?.id else { return }
    let userRef = firestore.collection(userPath).document(uid)
    let profileImageID = userRef.documentID
    let picRef = storageRef.child("\(uid)/profile/\(profileImageID).jpg")
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    // upload image to storage
    let uploadTask = storageRef.child("\(uid)/profile/\(profileImageID).jpg").putData(image.pngData()!, metadata: metadata) { fullmetadata, err in
      if err != nil {
        print("Error uploading image")
        return
      }
    }
    
    // get url after done uploading
    uploadTask.observe(.success) { snapshot in
      snapshot.reference.downloadURL { [self] url, error in
        if error != nil {
          print(error?.localizedDescription)
        }
        else {
          print(url)
          self.firestore.collection(self.userPath).document(uid).updateData([
            "profileImageUrl": url!.absoluteString])
        }
      }
    }
  }

  func updateUserInfo(
    username: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    bio: String? = nil,
    gender: String? = nil,
    country: String? = nil,
    completion: ((Bool) -> Void)? = nil
  ) {
//    guard let user = user else {
//      return
//    }
//
//    // use write batch
//
//    if let username = username {
//      firestore.collection(self.userPath).document(user.id).updateData
//    }
//
  }

  func updateUserEmail(to email: String, completion: ((Bool) -> Void)? = nil) {
    // TODO: verify user email
    firebaseUser?.updateEmail(to: email) { error in
      if let error = error {
        self.logger.info("[Authentication] Update user email failed: \(error.localizedDescription)")
        completion?(false)
        return
      }
      completion?(true)
    }
  }

  func updateUserPassword(to password: String, completion: ((Bool) -> Void)? = nil) {
    firebaseUser?.updatePassword(to: password) { error in
      if let error = error {
        self.logger
          .info("[Authentication] Update user password failed: \(error.localizedDescription)")
        completion?(false)
        return
      }
      completion?(true)
    }
  }

  func updateUserPhoneNumber(
    withVerificationID id: String,
    verificationCode code: String,
    completion: ((Bool) -> Void)? = nil
  ) {
    let credential = PhoneAuthProvider.provider(auth: auth)
      .credential(withVerificationID: id, verificationCode: code)
    firebaseUser?.updatePhoneNumber(credential) { error in
      if let error = error {
        self.logger
          .info("[Authentication] Update user phone number failed: \(error.localizedDescription)")
        completion?(false)
        return
      }
      completion?(true)
    }
  }
  
  func checkCurrentUser(userID: String) -> Bool {
    if userID == user?.id {
      return true
    } else {
      return false
    }
  }

  func addBusiness(business: Business) {
    _ = firestore.collection(businessPath).addDocument(from: business)
  }

  func addCuisine(cuisine: Cuisine) {
    _ = firestore.collection(cuisinePath).addDocument(from: cuisine)
  }

  func addFood(food: Food) {
    _ = firestore.collection(foodPath).addDocument(from: food)
  }

  func addReview(review: Review) {
    _ = firestore.collection(reviewPath).addDocument(from: review)
  }

  func addUserBookmark(business: Business) {
    var bookmarks = user?.bookmarks
    bookmarks?.append(business.id!)
    firestore.collection(userPath).document(user!.id).updateData(["bookmarks" : FieldValue.arrayUnion([business.id!])])
  }

  func deleteUserBookmark(business: Business) {
    firestore.collection(userPath).document(user!.id).updateData(["bookmarks" : FieldValue.arrayRemove([business.id!])])
  }

  func isBookmarked(business: Business) -> Bool {
    user!.bookmarks.contains { $0 == business.id! }
  }

  func mockDb() {
    let b1 = Business(
      id: nil,
      name: "The Rhythms Restaurant",
      address: "7th floor, 33-35 Hàng Dầu, Hoàn Kiếm",
      city: "Hanoi",
      state: "Hanoi",
      zipcode: "100000",
      latitude: CLLocationDegrees(21.0290683),
      longitude: CLLocationDegrees(105.8492768),
      open: true,
      stars: 4.8,
      price: 2,
      phone: "+84968756488",
      website: "https://therhythmsrestaurant.com",
      openingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      closingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      foods: [],
      cuisines: [],
      reviews: []
    )
    let b2 = Business(
      id: nil,
      name: "Poke Hanoi",
      address: "11B Hàng Khay, Hoàn Kiếm",
      city: "Hanoi",
      state: "Hanoi",
      zipcode: "100000",
      latitude: CLLocationDegrees(21.0295518),
      longitude: CLLocationDegrees(105.8482436),
      open: true,
      stars: 4.8,
      price: 2,
      phone: "+84903483218",
      website: "https://www.pokesaigon.com",
      openingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      closingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      foods: [],
      cuisines: [],
      reviews: []
    )
    let b3 = Business(
      id: nil,
      name: "Al Sultan Resturant",
      address: "178B Xuân Diệu, Quảng An, Tây Hồ",
      city: "Hanoi",
      state: "Hanoi",
      zipcode: "100000",
      latitude: CLLocationDegrees(21.0651831),
      longitude: CLLocationDegrees(105.8236615),
      open: true,
      stars: 4.5,
      price: 2,
      phone: "+84964054041",
      website: "https://www.alsultanrest.com",
      openingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      closingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      foods: [],
      cuisines: [],
      reviews: []
    )
    let b4 = Business(
      id: nil,
      name: "Anita's Cantina",
      address: "36 Phố Quảng Bá, Quảng An, Tây Hồ",
      city: "Hanoi",
      state: "Hanoi",
      zipcode: "100000",
      latitude: CLLocationDegrees(21.0290683),
      longitude: CLLocationDegrees(105.8492768),
      open: true,
      stars: 4.8,
      price: 3,
      phone: "+84949009132",
      website: "https://www.anitascantina.com/",
      openingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      closingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      foods: [],
      cuisines: [],
      reviews: []
    )
    let b5 = Business(
      id: nil,
      name: "Pizza 4P's Lotte Center Hanoi",
      address: "Lotte Center Hà Nội, F1, A14-A18, 54 Liễu Giai, Cống Vị, Ba Đình",
      city: "Hanoi",
      state: "Hanoi",
      zipcode: "100000",
      latitude: CLLocationDegrees(21.0212257),
      longitude: CLLocationDegrees(105.8096772),
      open: false,
      stars: 4.8,
      price: 3,
      phone: "+842836220500",
      website: "https://pizza4ps.com/",
      openingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      closingHours: [.Mon: 1, .Tue: 1, .Wed: 1, .Thu: 1, .Fri: 1, .Sat: 1, .Sun: 1],
      foods: [],
      cuisines: [],
      reviews: []
    )
    addBusiness(business: b1)
    addBusiness(business: b2)
    addBusiness(business: b3)
    addBusiness(business: b4)
    addBusiness(business: b5)
  }
}

extension Double
{
  func truncate(places : Int)-> Double
  {
      return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
  }
}
