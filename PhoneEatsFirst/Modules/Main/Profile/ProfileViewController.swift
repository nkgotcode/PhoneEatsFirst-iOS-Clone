//
//  ProfileViewController.swift
//  ProfileViewController
//
//  Created by itsnk on 9/6/21.
//

import Foundation
import Resolver
import SDWebImage
import SwiftUI
import UIKit

class ProfileViewController: UIViewController {
  @Injected var repository: DataRepository
  var user: User!
  var scrollView: UIScrollView!
  var profileImageView: UIImageView!
  var displayName: UILabel!
  var buttonR: UIButton!
  var buttonL: UIButton!
  var bio: UITextView!
  var buttonsHStack: UIStackView!
  var followHStack: UIStackView!
  var followButton: UIButton!
  
//  init(user: User) {
//    self.user = user
//    super.init(nibName: nil, bundle: nil)
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
  
  override func viewDidLoad() {
    scrollView = UIScrollView(frame: view.safeAreaLayoutGuide.layoutFrame)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.isScrollEnabled = true
    scrollView.contentSize = CGSize(width: 400, height: 3000)
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: -2, bottom: 4, right: -4)
    view.addSubview(scrollView)
    
    // user with no profile picture
//    if user.profileImageUrl == nil {
//      profileImageView = UIImageView(image: UIImage(named: "person.crop.circle.fill"))
//      profileImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
//      profileImageView.contentMode = .scaleAspectFit
//      print("placeholder profile image")
//    } else { // user with profile picture
//      profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
//      profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!), completed: { [self]
//        downloadedImage, error, cacheType, url in
//        if let error = error {
//          print("error downloading image: \(error.localizedDescription)")
//          profileImageView = UIImageView(image: UIImage(named: "person.crop.circle.fill"))
//          profileImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
//          profileImageView.contentMode = .scaleAspectFit
//          print("placeholder profile image")
//        }
//        else {
//          print("successfully downloaded: \(String(describing: url))")
//          profileImageView.contentMode = .scaleAspectFit
//        }
//      })
//    }

    profileImageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
    profileImageView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
    profileImageView.contentMode = .scaleAspectFit
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(profileImageView)

    let userLabel = UILabel()
    userLabel.text = "@\(user.username)"
    userLabel.textColor = .systemGray
    userLabel.translatesAutoresizingMaskIntoConstraints = false

    displayName = UILabel()
    displayName.text = user.firstName + " " + user.lastName
    displayName.textColor = .systemPink
    displayName.translatesAutoresizingMaskIntoConstraints = false
    
    scrollView.addSubview(userLabel)
    scrollView.addSubview(displayName)

    let followersVStack = UIStackView()
    followersVStack.axis = .vertical
    followersVStack.distribution = .equalSpacing
    followersVStack.spacing = 4
    followersVStack.alignment = .center
    followersVStack.contentHuggingPriority(for: .horizontal)
    followersVStack.frame = CGRect(x: 10, y: 20, width: 100, height: 150)
    followersVStack.translatesAutoresizingMaskIntoConstraints = false

    let followingVStack = UIStackView()
    followingVStack.axis = .vertical
    followingVStack.distribution = .equalSpacing
    followingVStack.spacing = 4
    followingVStack.alignment = .center
    followingVStack.contentHuggingPriority(for: .horizontal)
    followingVStack.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
    followingVStack.translatesAutoresizingMaskIntoConstraints = false

    let followersBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 77))
    followersBtn.setTitle("Followers", for: .normal)
    followersBtn.setTitleColor(.systemPink, for: .normal)
    followersBtn.addTarget(self, action: #selector(followersBtnPressed), for: .touchUpInside)

    let followersCount = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 77))
    followersCount.text = String(describing: user.followers.count)
    followersCount.textColor = .systemPink

    let followingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    followingBtn.setTitle("Following", for: .normal)
    followingBtn.setTitleColor(.systemPink, for: .normal)
    followingBtn.addTarget(self, action: #selector(followingBtnPressed), for: .touchUpInside)

    let followingCount = UILabel()
    followingCount.text = String(describing: user.following.count)
    followingCount.textColor = .systemPink

    followingVStack.addArrangedSubview(followingBtn)
    followingVStack.addArrangedSubview(followingCount)

    followersVStack.addArrangedSubview(followersBtn)
    followersVStack.addArrangedSubview(followersCount)

    followHStack = UIStackView()
    followHStack.axis = .horizontal
    followHStack.distribution = .equalSpacing
    followHStack.spacing = 2
    followHStack.alignment = .top
    followHStack.backgroundColor = .systemGray
    followHStack.contentHuggingPriority(for: .vertical)
    followHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    followHStack.translatesAutoresizingMaskIntoConstraints = false

    followHStack.addArrangedSubview(followersVStack)
    followHStack.addArrangedSubview(followingVStack)
    
    bio = UITextView()
    bio.text = "This is the bio"
    bio.isEditable = false
    bio.isSelectable = false
    bio.translatesAutoresizingMaskIntoConstraints = false
    bio.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
    bio.backgroundColor = .brown
    
    // buttons
    buttonL = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    buttonL.setTitle("Edit Profile", for: .normal)
    buttonL.setTitleColor(.systemPink, for: .normal)
    buttonL.layer.borderColor = UIColor.systemPink.cgColor
    buttonL.layer.borderWidth = 1
    buttonL.layer.cornerRadius = 10
    buttonL.translatesAutoresizingMaskIntoConstraints = false
    buttonL.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
    
    buttonR = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    buttonR.setTitle("Settings", for: .normal)
    buttonR.setTitleColor(.systemPink, for: .normal)
    buttonR.layer.borderColor = UIColor.systemPink.cgColor
    buttonR.layer.borderWidth = 1
    buttonR.layer.cornerRadius = 10
    buttonR.translatesAutoresizingMaskIntoConstraints = false
    buttonR.addTarget(self, action: #selector(rightBtnPressed), for: .touchUpInside)
    
    followButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    followButton.setTitle("Follow", for: .normal)
//    followButton.setTitleColor(.systemPink, for: .normal)
    followButton.backgroundColor = .systemPink
    followButton.layer.borderColor = UIColor.systemPink.cgColor
    followButton.layer.borderWidth = 1
    followButton.layer.cornerRadius = 10
//    followButton.translatesAutoresizingMaskIntoConstraints = false
    followButton.addTarget(self, action: #selector(followersBtnPressed), for: .touchUpInside)
    
    buttonsHStack = UIStackView()
    buttonsHStack.axis = .horizontal
    buttonsHStack.distribution = .fillProportionally
    buttonsHStack.spacing = 4
    buttonsHStack.alignment = .bottom
    buttonsHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
    buttonsHStack.contentHuggingPriority(for: .vertical)
    buttonsHStack.translatesAutoresizingMaskIntoConstraints = false
    
    // check if user object is current user to display appropriate buttons
    if repository.user?.id != user.id {
      buttonsHStack.addArrangedSubview(followButton)
      buttonsHStack.widthAnchor.constraint(equalToConstant: 100).isActive = true
    } else {
      buttonsHStack.addArrangedSubview(buttonR)
      buttonsHStack.addArrangedSubview(buttonL)
      buttonL.widthAnchor.constraint(equalTo: buttonR.widthAnchor).isActive = true
      buttonsHStack.widthAnchor.constraint(equalToConstant: (scrollView.frame.width - 40) / 2).isActive = true
    }
    scrollView.addSubview(buttonsHStack)
    scrollView.addSubview(followHStack)
    scrollView.addSubview(bio)
    
    // line separator from the bio and reviews
    let separator = UIView()
    separator.backgroundColor = .systemGray
    separator.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(separator)
    
    // stackview for reviews
    let reviewsVStack = UIStackView()
    reviewsVStack.spacing = 8
    reviewsVStack.distribution = .equalSpacing
    reviewsVStack.axis = .vertical
    reviewsVStack.alignment = .center
//    reviewsVStack.backgroundColor = .purple
    reviewsVStack.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
    reviewsVStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(reviewsVStack)
    
    // loop to create reviewView
    for reviewID in user.userReviewsID {
      let review = repository.getReview(id: reviewID)
      let tagObjects = repository.getTagObjects(reviewID: reviewID)
//      let viewVC = UIHostingController(rootView: ReviewView(review: review!, tags: tagObjects, dismissAction: {self.dismiss( animated: true, completion: nil )}))
//
//      viewVC.view.frame = CGRect(x: 0, y: 0, width: 100, height: 130)
      let reviewView = ReviewViewController(review: review!, tagObjects: tagObjects)
      reviewsVStack.addArrangedSubview(reviewView.view)
      reviewsVStack.addConstraintsSubView(subview: reviewView.view)
      
    }

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      scrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
      
      buttonsHStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      buttonsHStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      buttonsHStack.topAnchor.constraint(equalTo: displayName.bottomAnchor, constant: 16),

      buttonsHStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsHStack.heightAnchor.constraint(equalToConstant: 50),

      followHStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      followHStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 32),
      followHStack.bottomAnchor.constraint(lessThanOrEqualTo: bio.topAnchor),
      followHStack.heightAnchor.constraint(equalToConstant: 60),
      followHStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),

      followersVStack.topAnchor.constraint(equalTo: followHStack.topAnchor),
      followersVStack.bottomAnchor.constraint(lessThanOrEqualTo: followHStack.bottomAnchor),
      followersVStack.leadingAnchor.constraint(lessThanOrEqualTo: followHStack.leadingAnchor),
      followersVStack.trailingAnchor.constraint(equalTo: followingVStack.leadingAnchor, constant: -2),
      followersVStack.widthAnchor.constraint(equalTo: followingVStack.widthAnchor),
      
      followingVStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      
      bio.topAnchor.constraint(equalTo: followersVStack.bottomAnchor, constant: 8),
      bio.bottomAnchor.constraint(equalTo: buttonsHStack.topAnchor, constant: -16),
      bio.leadingAnchor.constraint(equalTo: followHStack.leadingAnchor),
      bio.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      

      profileImageView.widthAnchor.constraint(equalToConstant: 100),
      profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
      profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
      profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      
      userLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 1),
      userLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
      userLabel.widthAnchor.constraint(equalToConstant: 150),
      userLabel.heightAnchor.constraint(equalToConstant: 30),
      
      displayName.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 4),
      displayName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
      displayName.widthAnchor.constraint(equalToConstant: 150),
      displayName.heightAnchor.constraint(equalToConstant: 40),
      
      separator.topAnchor.constraint(equalTo: buttonsHStack.bottomAnchor, constant: 24),
      separator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      separator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      separator.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      separator.heightAnchor.constraint(equalToConstant: 1),
      
      reviewsVStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
      reviewsVStack.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
      reviewsVStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      reviewsVStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      reviewsVStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      reviewsVStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
    ])
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
//    let b = buttonsHStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
//    b.priority = UILayoutPriority(rawValue: 750)
//    b.isActive = true
//
//    let f = followHStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
//    f.priority = UILayoutPriority(rawValue: 750)
//    f.isActive = true
  }
  
  @objc func followBtnPressed() {
    
  }

  @objc func followersBtnPressed() {
    let followerVC = UIHostingController(rootView: FollowerView())
    followerVC.modalPresentationStyle = .formSheet

    if #available(iOS 15.0, *) {
      present(followerVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(followerVC, animated: true)
    }
  }

  @objc func followingBtnPressed() {
    let followingVC = UIHostingController(rootView: FollowingView())
    followingVC.modalPresentationStyle = .pageSheet
    
    if #available(iOS 15.0, *) {
      present(followingVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(followingVC, animated: true)
    }
  }
  
  @objc func rightBtnPressed() {
    let editVC = UIHostingController(rootView: EditProfileView())
    editVC.modalPresentationStyle = .pageSheet
    editVC.navigationItem.title = "Edit Profile"

    if #available(iOS 15.0, *) {
      present(editVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(editVC, animated: true)
    }
  }
  
  @objc func leftBtnPressed() {
    let settingsVC = UIHostingController(rootView: SettingsView())
    settingsVC.modalPresentationStyle = .pageSheet
    settingsVC.navigationItem.title = "Settings"

    if #available(iOS 15.0, *) {
      present(settingsVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(settingsVC, animated: true)
    }
  }
}

extension UIView {
  func addConstraintsSubView(subview: UIView) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
//      subview.topAnchor.constraint(equalTo: self.topAnchor),
      subview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//      subview.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
}
