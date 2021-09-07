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

  override func viewDidLoad() {
    scrollView = UIScrollView(frame: view.safeAreaLayoutGuide.layoutFrame)
    scrollView.bounces = true
    view.addSubview(scrollView)

//    let viewVStack = UIStackView()
//    viewVStack.axis = .vertical
//    viewVStack.alignment = .leading
//    viewVStack.translatesAutoresizingMaskIntoConstraints = false
//    scrollView.addSubview(viewVStack)
//

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
//      scrollView.addSubview(profileImageView)

    let userLabel = UILabel()
    userLabel.text = "@\(user.username)"
    userLabel.textColor = .systemGray

    displayName = UILabel()
    displayName.text = user.firstName + " " + user.lastName
    displayName.textColor = .black

    let followersVStack = UIStackView()
    followersVStack.axis = .vertical
    followersVStack.distribution = .equalSpacing
    followersVStack.spacing = 4
    followersVStack.alignment = .center
    followersVStack.backgroundColor = .blue
    followersVStack.contentHuggingPriority(for: .horizontal)
    followersVStack.frame = CGRect(x: 10, y: 20, width: 100, height: 150)
    followersVStack.translatesAutoresizingMaskIntoConstraints = false

    let followingVStack = UIStackView()
    followingVStack.axis = .vertical
    followingVStack.distribution = .equalSpacing
    followingVStack.spacing = 4
    followingVStack.alignment = .center
    followingVStack.backgroundColor = .brown
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

    let followHStack = UIStackView()
    followHStack.axis = .horizontal
    followHStack.distribution = .equalCentering
    followHStack.spacing = 4
    followHStack.alignment = .top
    followHStack.backgroundColor = .gray
    followHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    followHStack.translatesAutoresizingMaskIntoConstraints = false

    followHStack.addArrangedSubview(followersVStack)
    followHStack.addArrangedSubview(followingVStack)

    let picAndNameVStack = UIStackView()
    picAndNameVStack.axis = .vertical
    picAndNameVStack.distribution = .fillProportionally
    picAndNameVStack.spacing = 2
    picAndNameVStack.alignment = .center
    picAndNameVStack.backgroundColor = .red
    picAndNameVStack.contentHuggingPriority(for: .horizontal)
    picAndNameVStack.frame = CGRect(x: 0, y: 0, width: 100, height: 160)

    picAndNameVStack.addArrangedSubview(profileImageView)
    picAndNameVStack.addArrangedSubview(userLabel)
    picAndNameVStack.addArrangedSubview(displayName)
    
    // buttons
    
    
    let buttonsHStack = UIStackView()
    buttonsHStack.axis = .horizontal
    buttonsHStack.distribution = .fillProportionally
    buttonsHStack.spacing = 4
    buttonsHStack.backgroundColor = .magenta
    buttonsHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
    buttonsHStack.translatesAutoresizingMaskIntoConstraints = false
    

    let profileHStack = UIStackView()
    profileHStack.frame = CGRect(x: 0, y: 0, width: 300, height: 440)
    profileHStack.axis = .horizontal
    profileHStack.distribution = .equalCentering
    profileHStack.alignment = .top
    profileHStack.spacing = 16
    profileHStack.backgroundColor = .green
    profileHStack.translatesAutoresizingMaskIntoConstraints = false

    profileHStack.addArrangedSubview(picAndNameVStack)
    profileHStack.addArrangedSubview(followHStack)
    scrollView.addSubview(profileHStack)

    NSLayoutConstraint.activate([
      profileHStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
      profileHStack.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
      profileHStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      profileHStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      profileHStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      profileHStack.heightAnchor.constraint(equalToConstant: 240),

      followHStack.trailingAnchor.constraint(equalTo: profileHStack.trailingAnchor),
      followHStack.leadingAnchor.constraint(
        lessThanOrEqualTo: picAndNameVStack.trailingAnchor,
        constant: 64
      ),
      followHStack.bottomAnchor.constraint(lessThanOrEqualTo: profileHStack.bottomAnchor),
      followHStack.topAnchor.constraint(equalTo: profileHStack.topAnchor),

      followersVStack.topAnchor.constraint(equalTo: followHStack.topAnchor),
      followersVStack.bottomAnchor.constraint(lessThanOrEqualTo: followHStack.bottomAnchor),
      followersVStack.leadingAnchor.constraint(lessThanOrEqualTo: followHStack.leadingAnchor),
      followersVStack.trailingAnchor.constraint(equalTo: followingVStack.leadingAnchor, constant: -4),
      followersVStack.widthAnchor.constraint(equalTo: followingVStack.widthAnchor),
      
      followingVStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
      
      profileImageView.widthAnchor.constraint(equalToConstant: 100),
      profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
      
    ])
  }

  @objc func followersBtnPressed() {
    let followerVC = UIHostingController(rootView: FollowerView())
    followerVC.modalPresentationStyle = .formSheet
    navigationController?.pushViewController(followerVC, animated: true)
  }

  @objc func followingBtnPressed() {
    let followingVC = UIHostingController(rootView: FollowingView())
    followingVC.modalPresentationStyle = .formSheet
    navigationController?.pushViewController(followingVC, animated: true)
  }
}
