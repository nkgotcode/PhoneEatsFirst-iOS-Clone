//
//  FeedReviewView.swift
//  FeedReviewView
//
//  Created by itsnk on 9/9/21.
//

import Foundation
import UIKit
import Resolver

class FeedReviewView: UIViewController {
  @Injected private var repository: DataRepository
  var scrollView: UIScrollView!
  var review: Review!
  var tagObjects: [ReviewTag]!
  var profilePictureModel: ProfilePictureModel!
  
  override func viewDidLoad() {
    scrollView = UIScrollView()
    scrollView.isScrollEnabled = true
    scrollView.contentSize = CGSize(width: 400, height: view.frame.height)
    scrollView.backgroundColor = .systemBackground
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    let reviewView = ReviewViewController(review: review, tagObjects: tagObjects)
    reviewView.profilePictureModel = profilePictureModel
    reviewView.preferredContentSize = CGSize(width: 400, height: view.frame.height)
    reviewView.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(reviewView)
    reviewView.didMove(toParent: self)
    scrollView.addSubview(reviewView.view)
    
    let profileBtn = UIButton()
    profileBtn.translatesAutoresizingMaskIntoConstraints = false
    profileBtn.backgroundColor = .clear
    profileBtn.addTarget(self, action: #selector(profileBtnPressed), for: .touchUpInside)
    scrollView.addSubview(profileBtn)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      
      reviewView.view.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
      reviewView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      reviewView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
      reviewView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      reviewView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      reviewView.view.heightAnchor.constraint(lessThanOrEqualTo: scrollView.heightAnchor),
      
      profileBtn.topAnchor.constraint(equalTo: reviewView.userDetailHStack.topAnchor),
      profileBtn.leadingAnchor.constraint(equalTo: reviewView.userDetailHStack.leadingAnchor),
      profileBtn.bottomAnchor.constraint(equalTo: reviewView.profileImageView.bottomAnchor),
      profileBtn.widthAnchor.constraint(equalToConstant: 44 + reviewView.userLabel.frame.width),
    ])
  }
  
  @objc func profileBtnPressed() {
    if repository.user!.id != review.userId {
      let profileVC = ProfileViewController()
      let chosenUser = repository.getUser(id: review.userId)
      profileVC.user = chosenUser
      profileVC.profilePictureModel = profilePictureModel
      navigationController?.pushViewController(profileVC, animated: true)
    }
  }
}
