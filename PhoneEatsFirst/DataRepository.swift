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

  @Published private var firebaseUser: FirebaseAuth.User? = nil
  @Published var user: User? = nil

  let logger = Logger(subsystem: "com.itsnk.PhoneEatsFirst", category: "Repository")

  private let auth = Auth.auth()
  private let firestore = Firestore.firestore()
  let storage = Storage.storage()

//  let storageRef = storage.reference()
//  let postImageRef = storageRef.child("postImages")
//  let profileImageRef = storageRef.child("profileImages")

  private let businessPath = "businesses"
  private let cuisinePath = "cuisines"
  private let foodPath = "foods"
  private let reviewPath = "reviews"
  private let userPath = "users"

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
  
  func getDisplayTimestamp(creationDate: Timestamp) -> String {
    let postDate = Date(timeIntervalSince1970: TimeInterval(creationDate.seconds))
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    let ret = formatter.localizedString(for: postDate, relativeTo: Date())
    return ret
  }
  
  func getTruncatedRatings(ratings: Double) -> Double {
    ratings.truncate(places: 2)
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

  func uploadPost(image: UIImage, description: String?, businessId: String, foodRating: Double, serviceRating: Double, atmosphereRating: Double, valueRating: Double, tags: [ReviewTag], additionalComment: String?) {
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
    
    let uploadTask = storageRef.child("\(uid)/ori/\(postId).jpg").putData(resizedImage.pngData()!, metadata: metadata) { fullmetadata, err in
      if err != nil {
        print("Error uploading image")
        return
      }
    }
    
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
      
      let review = Review(
        id: postId, description: description, userId: uid, businessId: businessId, imageUrl: url, foodRating: foodRating, serviceRating: serviceRating, atmosphereRating: atmosphereRating, valueRating: valueRating, rating: totalRatings, tags: tags, edited: false, additionalComment: additionalComment, creationDate: nil)
      
      _ = self.firestore.collection(self.reviewPath).document(postId).setData(from: review)

      var userReviewsID = self.user?.userReviewsID
      userReviewsID?.append(postId)
      _ = self.firestore.collection(userPath).document(uid).updateData([
        "userReviewsID": userReviewsID])
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
        profileImageUrl: nil,
        creationDate: nil,
        lastLoginDate: nil
      )
      _ = self.firestore.collection(self.userPath)
        .document(result.user.uid)
        .setData(from: user)

      completion?(true)
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
