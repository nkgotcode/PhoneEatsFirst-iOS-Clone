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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.reviewID = user.userReviewsID
    
    NotificationCenter.default.addObserver(self, selector: #selector(onPostNotification), name: PostViewController.postNotification, object: nil)
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    
    followingReview = repository.getFollowingReviews(following: user.following)
    self.reviewID?.append(contentsOf: followingReview)
    
    if (reviewID!.count <= 0) {
      return
    }
    else {
      let layout: CustomCollectionViewFlowLayout = CustomCollectionViewFlowLayout(display: .list, containerWidth: view.bounds.size.width)
      layout.sectionInset = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
      layout.itemSize = CGSize(width: ((view.bounds.size.width - 16 - 8) / 2), height: ((view.bounds.size.width - 16 - 8) / 2))
      
      collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
      collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
      collectionView?.delegate = self
      collectionView?.dataSource = self
//      collectionView?.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(collectionView!)
      
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if (reviewID!.count <= 0) {
      return
    } else {
      collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
  }
  
  override func viewWillLayoutSubviews() {
//    super.viewWillLayoutSubviews()
//    collectionView?.collectionViewLayout.invalidateLayout()
//    layout?.collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    guard let previousTraitCollection = previousTraitCollection, traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass ||
        traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass else {
            return
    }

    if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
        // iPad portrait and landscape
        // do something here...
      layout?.collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
        // iPhone portrait
        // do something here...
    }
    if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .compact {
        // iPhone landscape
        // do something here...
      layout?.collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      layout?.collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      layout?.collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      layout?.collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    collectionView?.collectionViewLayout.invalidateLayout()
    collectionView?.reloadData()
  }
  
  private func reloadCollectionViewLayout(_ width: CGFloat) {
    self.layout!.containerWidth = width
    self.layout?.display = self.view.traitCollection.horizontalSizeClass == .compact && self.view.traitCollection.verticalSizeClass == .regular ? CollectionDisplay.list : CollectionDisplay.grid(columns: 2)
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
    
//    let size = CGSize(width: 100.0, height: 20)
//    let roundedView = UIView(frame: CGRect(origin: .zero, size: size))
//    roundedView.translatesAutoresizingMaskIntoConstraints = false
//    // Creating the layer that we'll use as a mask
//    let mask = CAShapeLayer()
//    // Set its frame to the view bounds
//    mask.frame = roundedView.bounds
//    // Build its path with a smoothed shape
//    mask.path = UIBezierPath(roundedRect: roundedView.bounds, cornerRadius: 10.0).cgPath
//    // Apply the mask to the view
//    roundedView.layer.mask = mask
//    roundedView.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
//    c.contentView.addSubview(roundedView)
//    
//    NSLayoutConstraint.activate([
//      roundedView.topAnchor.constraint(equalTo: c.contentView.topAnchor, constant: 8),
//      roundedView.leadingAnchor.constraint(equalTo: c.contentView.leadingAnchor, constant: 16),
//      roundedView.trailingAnchor.constraint(equalTo: c.contentView.trailingAnchor, constant: 16),
//    ])
    return c
  }
  
}

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let reviewID = reviewDict[indexPath.row]!
    let review = repository.getReview(id: reviewID)
    let tags = repository.getTagObjects(reviewID: reviewID)
    let chosenUser = repository.getUser(id: review!.userId)
    let profilePictureModel = ProfilePictureModel(user: chosenUser!, profileImage: UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate), imgView: UIImageView())
    let reviewVC = ReviewViewController(review: review!, tagObjects: tags)
    reviewVC.profilePictureModel = profilePictureModel

//    if #available(iOS 15.0, *) {
//      navigationController?.present(reviewVC, animated: true, completion: nil)
//    } else {
      navigationController?.pushViewController(reviewVC, animated: true)
//    }
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

