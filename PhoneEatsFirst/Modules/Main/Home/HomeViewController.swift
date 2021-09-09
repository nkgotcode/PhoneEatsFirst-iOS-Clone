//
//  HomeViewController.swift
//  HomeViewController
//
//  Created by itsnk on 9/5/21.
//

import Foundation
import UIKit
import Resolver
import SwiftUI
import SDWebImage

enum CollectionDisplay {
  case list
  case grid(columns: Int)
}

class HomeViewController: UIViewController {
  @Injected private var repository: DataRepository
  var collectionView: UICollectionView?
  var user: User!
  var layout: CustomCollectionViewFlowLayout?
  var reviewID: [String]?
  var reviewDict = [Int:String]()
  var followingReview: [String]!
  var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.reviewID = user.userReviewsID
    followingReview = repository.getFollowingReviews(following: user.following)
    self.reviewID?.append(contentsOf: followingReview)
    
    scrollView = UIScrollView()
    scrollView.isScrollEnabled = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    if (reviewID!.count <= 0) {
      return
    }
    else {
      let layout: CustomCollectionViewFlowLayout = CustomCollectionViewFlowLayout(display: .list, containerWidth: view.bounds.size.width)
      layout.sectionInset = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
      layout.itemSize = CGSize(width: 120, height: 120)
      
      collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
      collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
      collectionView?.delegate = self
      collectionView?.dataSource = self
      scrollView.contentSize = CGSize(width: 400, height: 2300)
      scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: -2, bottom: 4, right: -4)
//      view.addSubview(collectionView!)
      scrollView.addSubview(collectionView!)
      
      NSLayoutConstraint.activate([
        scrollView.topAnchor.constraint(equalTo: view.topAnchor),
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//        scrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
      ])
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView?.collectionViewLayout.invalidateLayout()
    layout?.collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }
  
  private func reloadCollectionViewLayout(_ width: CGFloat) {
    self.layout!.containerWidth = width
    self.layout?.display = self.view.traitCollection.horizontalSizeClass == .compact && self.view.traitCollection.verticalSizeClass == .regular ? CollectionDisplay.list : CollectionDisplay.grid(columns: 2)
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    let users = repository.users
//    for u in users {
//      self.reviewID?.append(contentsOf: u.userReviewsID)
//    }
//  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = (view.bounds.size.width - 24) / 2
    let cellHeight = cellWidth
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
}

extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return reviewID!.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let review = repository.getReview(id: reviewID![indexPath.row])
    let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    
    let placeholder = UIImageView(image: UIImage(named: "placeholder"))
    placeholder.sd_setImage(with: URL(string: review!.imageUrl), placeholderImage: UIImage(named: "placeholder"), completed: {
      downloadedImage, error, cacheType, url in
      if let error = error {
        print("error downloading image: \(error.localizedDescription)")
      }
      else {
        print("successfully downloaded: \(String(describing: url))")
      }
    })
    
    c.backgroundView = placeholder
    c.backgroundView!.layer.cornerRadius = 16
    c.backgroundView!.layer.borderWidth = 1
    c.backgroundView!.layer.borderColor = UIColor.clear.cgColor
    c.backgroundView!.layer.masksToBounds = true
    reviewDict[indexPath.row] = reviewID![indexPath.row]
    return c
  }
  
  
}

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let reviewID = reviewDict[indexPath.row]!
    let review = repository.getReview(id: reviewID)
    let tags = repository.getTagObjects(reviewID: reviewID)
    let reviewVC = UIHostingController(rootView: ReviewView(review: review!, tags: tags, dismissAction: {self.dismiss( animated: true, completion: nil )}))
    reviewVC.modalPresentationStyle = .pageSheet
    reviewVC.view.frame = UIScreen.main.bounds
    reviewVC.loadViewIfNeeded()

    if #available(iOS 15.0, *) {
      navigationController?.present(reviewVC, animated: true, completion: nil)
    } else {
      navigationController?.pushViewController(reviewVC, animated: true)
    }
  }
  
}

extension CollectionDisplay: Equatable {
  public static func == (lhs: CollectionDisplay, rhs: CollectionDisplay) -> Bool {
    switch(lhs,rhs) {
      case (.list, .list): return true
      case (.grid(columns: let lColumn), .grid(columns: let rColumn)):
              return lColumn == rColumn
      default: return false
    }
  }
}

class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
  var display: CollectionDisplay = .list {
    didSet {
      if display != oldValue {
        self.invalidateLayout()
      }
    }
  }
  
  var containerWidth: CGFloat = 0 {
    didSet {
      if containerWidth != oldValue {
        self.invalidateLayout()
      }
    }
  }
  
  convenience init(display: CollectionDisplay, containerWidth: CGFloat) {
    self.init()
    self.display = display
    self.containerWidth = containerWidth
    self.minimumLineSpacing = 8
    self.minimumInteritemSpacing = 8
    
  }
  
  func configLayout() {
    switch display {
    case .list:
      self.scrollDirection = .vertical
      self.itemSize = CGSize(width: (containerWidth - 32), height: (containerWidth - 32))
    case .grid(columns: let column):
      self.scrollDirection = .vertical
      self.itemSize = CGSize (width: (containerWidth - 40)/2, height: (containerWidth - 32)/2)
    }
  }
  
  override func invalidateLayout() {
    super.invalidateLayout()
    self.configLayout()
  }
}
