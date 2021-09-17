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
import Combine

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
  var followedButton: UIButton!
  var profilePictureModel: ProfilePictureModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    NotificationCenter.default.addObserver(self, selector: #selector(onPostNotification), name: PostViewController.postNotification, object: nil)
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    
    scrollView = UIScrollView(frame: view.safeAreaLayoutGuide.layoutFrame)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.isScrollEnabled = true
    scrollView.contentSize = CGSize(width: 400, height: view.frame.height)
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: -2, bottom: 4, right: -4)
    scrollView.refreshControl = refreshControl
    view.addSubview(scrollView)
    
    profileImageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate))
    profilePictureModel = ProfilePictureModel(user: user, profileImage: UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate), imgView: profileImageView)
    profileImageView = profilePictureModel.imgView
    
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
    displayName.font = displayName.font.bold
    displayName.translatesAutoresizingMaskIntoConstraints = false
    
    scrollView.addSubview(userLabel)
    scrollView.addSubview(displayName)

    let followersVStack = UIStackView()
    followersVStack.axis = .vertical
    followersVStack.distribution = .equalCentering
    followersVStack.spacing = 4
    followersVStack.alignment = .center
    followersVStack.contentHuggingPriority(for: .horizontal)
    followersVStack.frame = CGRect(x: 10, y: 20, width: 100, height: 150)
    followersVStack.translatesAutoresizingMaskIntoConstraints = false

    let followingVStack = UIStackView()
    followingVStack.axis = .vertical
    followingVStack.distribution = .equalCentering
    followingVStack.spacing = 4
    followingVStack.alignment = .center
    followingVStack.contentHuggingPriority(for: .horizontal)
    followingVStack.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
    followingVStack.translatesAutoresizingMaskIntoConstraints = false
    
    let followersBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 77))
    followersBtn.titleLabel?.lineBreakMode = .byWordWrapping
    followersBtn.titleLabel?.numberOfLines = 2
    followersBtn.setTitle("Followers\n\(user.followers.count)", for: .normal)
    followersBtn.setTitleColor(.systemPink, for: .normal)
    followersBtn.titleLabel?.textAlignment = .center
    followersBtn.titleLabel?.font = followersBtn.titleLabel?.font.bold
    followersBtn.sizeToFit()
    followersBtn.addTarget(self, action: #selector(followersBtnPressed), for: .touchUpInside)

    let followingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    followingBtn.titleLabel?.lineBreakMode = .byWordWrapping
    followingBtn.titleLabel?.numberOfLines = 2
    followingBtn.setTitle("Following\n\(user.following.count)", for: .normal)
    followingBtn.titleLabel?.font = followingBtn.titleLabel?.font.bold
    followingBtn.setTitleColor(.systemPink, for: .normal)
    followingBtn.titleLabel?.textAlignment = .center
    followingBtn.sizeToFit()
    followingBtn.addTarget(self, action: #selector(followingBtnPressed), for: .touchUpInside)

    followingVStack.addArrangedSubview(followingBtn)
    
    followersVStack.addArrangedSubview(followersBtn)

    followHStack = UIStackView()
    followHStack.axis = .horizontal
    followHStack.distribution = .equalSpacing
    followHStack.spacing = 2
    followHStack.alignment = .top
    followHStack.contentHuggingPriority(for: .vertical)
    followHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    followHStack.translatesAutoresizingMaskIntoConstraints = false

    followHStack.addArrangedSubview(followersVStack)
    followHStack.addArrangedSubview(followingVStack)
    
    bio = UITextView()
    bio.text = "Bio"
    bio.font = bio.font?.withSize(16)
    bio.isEditable = false
    bio.isSelectable = false
    bio.translatesAutoresizingMaskIntoConstraints = false
    bio.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
    
    // buttons
    buttonL = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    buttonL.setTitle("Edit Profile", for: .normal)
//    buttonL.setTitleColor(.systemPink, for: .normal)
    buttonL.titleLabel?.font = buttonL.titleLabel?.font.withSize(16).bold
    buttonL.layer.borderColor = UIColor.systemPink.cgColor
    buttonL.layer.borderWidth = 2
    buttonL.layer.cornerRadius = 10
    buttonL.translatesAutoresizingMaskIntoConstraints = false
    buttonL.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
    
    buttonR = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    buttonR.setTitle("Settings", for: .normal)
//    buttonR.setTitleColor(.systemPink, for: .normal)
    buttonR.layer.borderColor = UIColor.systemPink.cgColor
    buttonR.titleLabel?.font = buttonR.titleLabel?.font.withSize(16).bold
    buttonR.layer.borderWidth = 2
    buttonR.layer.cornerRadius = 10
    buttonR.translatesAutoresizingMaskIntoConstraints = false
    buttonR.addTarget(self, action: #selector(rightBtnPressed), for: .touchUpInside)
    
    followButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    followButton.setTitle("Follow", for: .normal)
    followButton.titleLabel?.font = followButton.titleLabel?.font.withSize(16).bold
    followButton.backgroundColor = .systemPink
    followButton.layer.borderWidth = 2
    followButton.layer.cornerRadius = 10
//    followButton.translatesAutoresizingMaskIntoConstraints = false
    followButton.addTarget(self, action: #selector(followBtnPressed), for: .touchUpInside)
    
    followedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    followedButton.setTitle("Following", for: .normal)
    followedButton.titleLabel?.font = followedButton.titleLabel?.font.withSize(16).bold
    followedButton.layer.borderColor = UIColor.systemPink.cgColor
    followedButton.layer.borderWidth = 2
    followedButton.layer.cornerRadius = 10
//    followButton.translatesAutoresizingMaskIntoConstraints = false
    followedButton.addTarget(self, action: #selector(followedBtnPressed), for: .touchUpInside)
    
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
      // if already followed
      if ((repository.user?.following.contains(user.id)) != nil) {
        buttonsHStack.addArrangedSubview(followedButton)
      } else {
        buttonsHStack.addArrangedSubview(followButton)
      }
      buttonsHStack.widthAnchor.constraint(equalToConstant: 100).isActive = true

    } else {
      buttonsHStack.addArrangedSubview(buttonL)
      buttonsHStack.addArrangedSubview(buttonR)
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
    reviewsVStack.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
    reviewsVStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(reviewsVStack)
    
    // loop to create reviewView
    for (n, reviewID) in user.userReviewsID.reversed().enumerated() {
      let review = repository.getReview(id: reviewID)
      let tagObjects = repository.getTagObjects(reviewID: reviewID)
      let reviewView = ReviewViewController(review: review!, tagObjects: tagObjects)
      reviewsVStack.spacing = reviewView.view.frame.height + 8
      addChild(reviewView)
      reviewView.didMove(toParent: self)
      reviewsVStack.addArrangedSubview(reviewView.view)
      if n > 0 {
        let previousSubview = reviewsVStack.arrangedSubviews[n-1]
        reviewsVStack.addConstraintsSubView(subview: reviewView.view, previousSubview: previousSubview)
      } else {
        reviewView.view.translatesAutoresizingMaskIntoConstraints = false
        reviewView.view.topAnchor.constraint(equalTo: reviewsVStack.topAnchor).isActive = true
        reviewView.view.leadingAnchor.constraint(equalTo: reviewsVStack.leadingAnchor).isActive = true
        reviewView.view.trailingAnchor.constraint(equalTo: reviewsVStack.trailingAnchor).isActive = true
      }
    }

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      buttonsHStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      buttonsHStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
      buttonsHStack.topAnchor.constraint(equalTo: displayName.bottomAnchor, constant: 16),

      buttonsHStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsHStack.heightAnchor.constraint(equalToConstant: 50),

      followHStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      followHStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 32),
      followHStack.bottomAnchor.constraint(lessThanOrEqualTo: bio.topAnchor),
      followHStack.heightAnchor.constraint(equalToConstant: 60),
      followHStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),

      followersVStack.topAnchor.constraint(equalTo: followHStack.topAnchor),
      followersVStack.bottomAnchor.constraint(lessThanOrEqualTo: followHStack.bottomAnchor),
      followersVStack.leadingAnchor.constraint(lessThanOrEqualTo: followHStack.leadingAnchor),
      followersVStack.trailingAnchor.constraint(equalTo: followingVStack.leadingAnchor, constant: -2),
      followersVStack.widthAnchor.constraint(equalTo: followingVStack.widthAnchor),
      
      followingVStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      
      bio.topAnchor.constraint(equalTo: followersVStack.bottomAnchor, constant: 8),
      bio.bottomAnchor.constraint(equalTo: buttonsHStack.topAnchor, constant: -16),
      bio.leadingAnchor.constraint(equalTo: followHStack.leadingAnchor),
      bio.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      

      profileImageView.widthAnchor.constraint(equalToConstant: 100),
      profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
      profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
      profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
      
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
      
      reviewsVStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
      reviewsVStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      reviewsVStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      reviewsVStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      reviewsVStack.heightAnchor.constraint(equalToConstant: CGFloat(590 * user.userReviewsID.count)),
    ])
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  @objc func refreshData(refresh: UIRefreshControl) {
    user = repository.user
    let parent = self.view.superview
    self.view.removeFromSuperview()
    self.view = nil
    parent?.addSubview(self.view)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      refresh.endRefreshing()
    }
  }
  
  @objc func onPostNotification() {
    user = repository.user
    let parent = self.view.superview
    self.view.removeFromSuperview()
    self.view = nil
    parent?.addSubview(self.view)
    print("got post noti")
  }
  
  @objc func followedBtnPressed() {
    buttonsHStack.removeArrangedSubview(followedButton)
    followedButton.removeFromSuperview()
    buttonsHStack.addArrangedSubview(followButton)
    repository.unfollowUser(id: user.id)
  }
  
  @objc func followBtnPressed() {
    buttonsHStack.removeArrangedSubview(followButton)
    followButton.removeFromSuperview()
    buttonsHStack.addArrangedSubview(followedButton)
    repository.followUser(id: user.id)
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
    let settingsVC = UIHostingController(rootView: SettingsView())
    settingsVC.modalPresentationStyle = .pageSheet
    settingsVC.navigationItem.title = "Settings"

    if #available(iOS 15.0, *) {
      present(settingsVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(settingsVC, animated: true)
    }
  }
  
  @objc func leftBtnPressed() {
    let editVC = UIHostingController(rootView: EditProfileView(user: user, profilePictureModel: profilePictureModel))
    editVC.modalPresentationStyle = .pageSheet
    editVC.navigationItem.title = "Edit Profile"
    editVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEditBtn))
    if #available(iOS 15.0, *) {
      present(editVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(editVC, animated: true)
    }
  }
  
  @objc func saveEditBtn() {
    // user hasn't changed profile image
    if profilePictureModel.profileImage.pngData() == UIImage(systemName: "person.crop.circle.fill")?.pngData() {
      
    } else {
      profilePictureModel.newProfileChange = true
      profilePictureModel.registerNewChange()
      repository.uploadProfilePicture(image: profilePictureModel.profileImage)
    }
    navigationController?.popViewController(animated: true)
  }
}

class ProfilePictureModel: ObservableObject {
  @Published var profileImage = UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate)
  @Published var newProfileChange = false
  var imgView = UIImageView()
  var user: User!
  
  init(user: User, profileImage: UIImage, imgView: UIImageView) {
    if user.profileImageUrl != "" || user.profileImageUrl != nil {
      imgView.sd_setImage(with: URL(string: user.profileImageUrl!), completed: { [self]
        downloadedImage, error, cacheType, url in
        if let error = error {
          print("error downloading image: \(error.localizedDescription)")
          self.profileImage = profileImage
        }
        else {
          print("successfully downloaded: \(String(describing: url))")
          self.profileImage = downloadedImage!
        }
      })
  
    }

    self.user = user
    self.imgView = UIImageView(image: self.profileImage)
  }
  
  func registerNewChange() {
    self.profileImage = profileImage.circle
    self.newProfileChange = false
  }
}

extension UIView {
  func addConstraintsSubView(subview: UIView, previousSubview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: previousSubview.topAnchor, constant: 590),
    ])
  }
}

extension UIImage {
  var circle: UIImage {
      let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
      let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
      imageView.contentMode = UIView.ContentMode.scaleAspectFill
      imageView.image = self
      imageView.layer.cornerRadius = square.width/2
      imageView.layer.masksToBounds = true
      UIGraphicsBeginImageContext(imageView.bounds.size)
      imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result!
  }
}
