//
//  ReviewViewController.swift
//  ReviewViewController
//
//  Created by itsnk on 9/8/21.
//

import Foundation
import UIKit
import Resolver
import SDWebImage

class ReviewViewController: UIViewController {
  @Injected private var repository: DataRepository
  var user: User!
  var review: Review!
  var profileImageView: UIImageView!
  var userLabel: UILabel!
  var restaurantLabel: UILabel!
  var priceLabel: UILabel!
  var ratingLabel: UILabel!
  var addressLabel: UILabel!
  var likeBtn: UIButton!
  var commentBtn: UIButton!
  var bookmarkBtn: UIButton!
  var postImageView: UIImageView!
  var additionalComment: UILabel!
  var menuBtn: UIButton!
  var tagObjects: [ReviewTag]!
  var profilePictureModel: ProfilePictureModel!
  var profileVC: ProfileViewController!
  var userDetailHStack: UIStackView!
  
  init(review: Review, tagObjects: [ReviewTag]) {
    self.review = review
    self.tagObjects = tagObjects
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    user = repository.getUser(id: review.userId)
    profileImageView = UIImageView()
    profilePictureModel = ProfilePictureModel(user: user, profileImage: UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate), imgView: profileImageView)
    profileImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
//    if user.profileImageUrl != nil {
//      profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!), completed: { [self]
//        downloadedImage, error, cacheType, url in
//        if let error = error {
//          print("error downloading image: \(error.localizedDescription)")
//          profileImageView = UIImageView(image: UIImage(named: "person.crop.circle.fill"))
//          profileImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//          profileImageView.contentMode = .scaleAspectFit
//          print("placeholder profile image")
//        }
//        else {
//          print("successfully downloaded: \(String(describing: url))")
//        }
//      })
//    }
    
    userLabel = UILabel()
    userLabel.text = user.username
    userLabel.textColor = .systemPink
    userLabel.font = userLabel.font.bold
    userLabel.font = userLabel.font.withSize(17)
    userLabel.translatesAutoresizingMaskIntoConstraints = false
    
    menuBtn = UIButton()
    menuBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
    menuBtn.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
    menuBtn.setContentHuggingPriority(.required, for: .horizontal)
    menuBtn.translatesAutoresizingMaskIntoConstraints = false
    
    userDetailHStack = UIStackView()
    userDetailHStack.axis = .horizontal
    userDetailHStack.alignment = .center
    userDetailHStack.distribution = .equalCentering
    userDetailHStack.spacing = 4
    userDetailHStack.contentHuggingPriority(for: .vertical)
    userDetailHStack.translatesAutoresizingMaskIntoConstraints = false
    
    userDetailHStack.addArrangedSubview(profileImageView)
    userDetailHStack.addArrangedSubview(userLabel)
    userDetailHStack.addArrangedSubview(menuBtn)
    view.addSubview(userDetailHStack)
    
    let business = repository.getBusiness(id: review.businessId)
    restaurantLabel = UILabel()
    restaurantLabel.text = business?.name
    restaurantLabel.font = restaurantLabel.font.withSize(12)
    restaurantLabel.font = restaurantLabel.font.italic
    restaurantLabel.translatesAutoresizingMaskIntoConstraints = false
    
    addressLabel = UILabel()
    addressLabel.text = business?.address
    addressLabel.font = addressLabel.font.withSize(12)
    addressLabel.font = addressLabel.font.italic
    addressLabel.translatesAutoresizingMaskIntoConstraints = false
    
    priceLabel = UILabel()
    priceLabel.text = String(repeating: "$", count: (business?.price)!)
    priceLabel.font = priceLabel.font.withSize(12)
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    
    ratingLabel = UILabel()
    let attachment = NSAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "star.fill")!))
    
    let completeText = NSMutableAttributedString(string: "")
    completeText.append(attachment)
    completeText.append(NSAttributedString(string: String(format: "%.2f", business?.stars as! CVarArg)))
    ratingLabel.textAlignment = .center
    ratingLabel.attributedText = completeText
    ratingLabel.font = ratingLabel.font.withSize(12)
    ratingLabel.translatesAutoresizingMaskIntoConstraints = false
    ratingLabel.textColor = .systemPink
    
    let reviewDetailHStack = UIStackView()
    reviewDetailHStack.axis = .horizontal
    reviewDetailHStack.alignment = .center
    reviewDetailHStack.distribution = .equalCentering
    reviewDetailHStack.spacing = 4
    reviewDetailHStack.contentHuggingPriority(for: .vertical)
    reviewDetailHStack.translatesAutoresizingMaskIntoConstraints = false
    
    reviewDetailHStack.addArrangedSubview(restaurantLabel)
    reviewDetailHStack.addArrangedSubview(priceLabel)
    reviewDetailHStack.addArrangedSubview(ratingLabel)
    reviewDetailHStack.addArrangedSubview(addressLabel)
    view.addSubview(reviewDetailHStack)
    
    postImageView = UIImageView(image: UIImage(named: "placeholder"))
    postImageView.translatesAutoresizingMaskIntoConstraints = false
    postImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    postImageView.layer.cornerRadius = 20
    postImageView.layer.masksToBounds = true
    postImageView.sd_setImage(with: URL(string: review.imageUrl), completed: {
      downloadedImage, error, cacheType, url in
      if let error = error {
        print("error downloading image: \(error.localizedDescription)")
      }
      else {
        print("successfully downloaded: \(String(describing: url))")
      }
    })
    
    likeBtn = UIButton()
    likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
    likeBtn.contentMode = .scaleAspectFit
    likeBtn.tintColor = .systemPink
    likeBtn.translatesAutoresizingMaskIntoConstraints = false
    likeBtn.addTarget(self, action: #selector(likeBtnPressed), for: .touchUpInside)
    
    commentBtn = UIButton()
    commentBtn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
    commentBtn.tintColor = .systemPink
    commentBtn.contentMode = .scaleAspectFit
    commentBtn.translatesAutoresizingMaskIntoConstraints = false
    commentBtn.addTarget(self, action: #selector(commentBtnPressed), for: .touchUpInside)
    
    bookmarkBtn = UIButton()
    bookmarkBtn.setImage(UIImage(systemName: "bookmark"), for: .normal)
    bookmarkBtn.tintColor = .systemPink
    bookmarkBtn.contentMode = .scaleAspectFit
    bookmarkBtn.translatesAutoresizingMaskIntoConstraints = false
    bookmarkBtn.addTarget(self, action: #selector(bookmarkBtnPressed), for: .touchUpInside)
    
    let imageAndActionVStack = UIStackView()
    imageAndActionVStack.axis = .vertical
    imageAndActionVStack.alignment = .center
    imageAndActionVStack.distribution = .equalCentering
    imageAndActionVStack.spacing = 4
    imageAndActionVStack.translatesAutoresizingMaskIntoConstraints = false
    
    let actionHStack = UIStackView()
    actionHStack.axis = .horizontal
    actionHStack.alignment = .center
    actionHStack.distribution = .equalCentering
    actionHStack.spacing = 4
    actionHStack.translatesAutoresizingMaskIntoConstraints = false
    
    actionHStack.addArrangedSubview(likeBtn)
    actionHStack.addArrangedSubview(commentBtn)
    actionHStack.addArrangedSubview(bookmarkBtn)
    
    imageAndActionVStack.addArrangedSubview(postImageView)
    imageAndActionVStack.addArrangedSubview(actionHStack)
    view.addSubview(imageAndActionVStack)
    
    let cmtUserLabel = UILabel()
    cmtUserLabel.text = user.username
    cmtUserLabel.textColor = .systemPink
    cmtUserLabel.font = cmtUserLabel.font.bold
    cmtUserLabel.font = cmtUserLabel.font.withSize(13)
    cmtUserLabel.textAlignment = .center
    cmtUserLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cmtUserLabel)
    
    let commentLabel = UILabel()
    commentLabel.translatesAutoresizingMaskIntoConstraints = false
    commentLabel.text = review.additionalComment
    commentLabel.font = commentLabel.font.withSize(13)
    commentLabel.numberOfLines = 2
    commentLabel.textAlignment = .left
    view.addSubview(commentLabel)
    
    NSLayoutConstraint.activate([
      userDetailHStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      userDetailHStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      userDetailHStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      userDetailHStack.heightAnchor.constraint(equalToConstant: 40),
      
      reviewDetailHStack.topAnchor.constraint(equalTo: userDetailHStack.bottomAnchor),
      reviewDetailHStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      reviewDetailHStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      reviewDetailHStack.heightAnchor.constraint(equalToConstant: 24),
      
      restaurantLabel.topAnchor.constraint(equalTo: reviewDetailHStack.topAnchor),
      restaurantLabel.bottomAnchor.constraint(equalTo: reviewDetailHStack.bottomAnchor),
      restaurantLabel.leadingAnchor.constraint(equalTo: reviewDetailHStack.leadingAnchor),
      restaurantLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
      
      priceLabel.topAnchor.constraint(equalTo: reviewDetailHStack.topAnchor),
      priceLabel.bottomAnchor.constraint(equalTo: reviewDetailHStack.bottomAnchor),
      priceLabel.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor),
      priceLabel.widthAnchor.constraint(equalToConstant: 40),
      
      ratingLabel.topAnchor.constraint(equalTo: reviewDetailHStack.topAnchor),
      ratingLabel.bottomAnchor.constraint(equalTo: reviewDetailHStack.bottomAnchor),
      ratingLabel.trailingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
      
      addressLabel.topAnchor.constraint(equalTo: reviewDetailHStack.topAnchor),
      addressLabel.bottomAnchor.constraint(equalTo: reviewDetailHStack.bottomAnchor),
      addressLabel.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor),
      addressLabel.trailingAnchor.constraint(equalTo: reviewDetailHStack.trailingAnchor),
      
      imageAndActionVStack.topAnchor.constraint(equalTo: reviewDetailHStack.bottomAnchor, constant: 8),
      imageAndActionVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageAndActionVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      postImageView.leadingAnchor.constraint(equalTo: imageAndActionVStack.leadingAnchor),
      postImageView.trailingAnchor.constraint(equalTo: imageAndActionVStack.trailingAnchor),
      postImageView.topAnchor.constraint(equalTo: imageAndActionVStack.topAnchor),
      postImageView.widthAnchor.constraint(equalTo: postImageView.heightAnchor),
      
      actionHStack.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
      actionHStack.leadingAnchor.constraint(equalTo: imageAndActionVStack.leadingAnchor),
      actionHStack.trailingAnchor.constraint(equalTo: imageAndActionVStack.trailingAnchor),
      actionHStack.heightAnchor.constraint(equalToConstant: 40),
      
      profileImageView.leadingAnchor.constraint(equalTo: userDetailHStack.leadingAnchor),
      profileImageView.topAnchor.constraint(equalTo: userDetailHStack.topAnchor),
      profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
      
      userLabel.topAnchor.constraint(equalTo: userDetailHStack.topAnchor),
      userLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
      userLabel.trailingAnchor.constraint(equalTo: menuBtn.leadingAnchor, constant: -64),
      
      menuBtn.topAnchor.constraint(equalTo: userDetailHStack.topAnchor),
      menuBtn.bottomAnchor.constraint(equalTo: userDetailHStack.bottomAnchor),
      menuBtn.trailingAnchor.constraint(equalTo: userDetailHStack.trailingAnchor),
      
      restaurantLabel.widthAnchor.constraint(equalToConstant: 120),
      
      likeBtn.heightAnchor.constraint(equalToConstant: 40),
      commentBtn.heightAnchor.constraint(equalToConstant: 40),
      bookmarkBtn.heightAnchor.constraint(equalToConstant: 40),
      
      cmtUserLabel.topAnchor.constraint(equalTo: actionHStack.bottomAnchor, constant: 4),
      cmtUserLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),

      commentLabel.leadingAnchor.constraint(equalTo: cmtUserLabel.trailingAnchor, constant: 4),
      commentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      commentLabel.topAnchor.constraint(equalTo: actionHStack.bottomAnchor, constant: 4),
      commentLabel.centerYAnchor.constraint(equalTo: cmtUserLabel.centerYAnchor),
    ])
  }
  
  @objc func likeBtnPressed() {
    print("likeBtnPressed")
  }
  
  @objc func commentBtnPressed() {
    let commentVC = CommentViewController()
    commentVC.review = review
    navigationController?.pushViewController(commentVC, animated: true)
    print("comment button pressed")
  }
  
  @objc func bookmarkBtnPressed() {
    print("bookmarkBtnPressed")
  }
}

extension UIFont {
    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }



    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
