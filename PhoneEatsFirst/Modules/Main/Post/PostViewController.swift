//
//  PostViewController.swift
//  PostViewController
//
//  Created by itsnk on 7/25/21.
//

import Cosmos
import CropViewController
import JGProgressHUD
import Resolver
import UIKit
import FirebaseStorage
import FirebaseFirestore

class PostViewController: UIViewController, UITextViewDelegate, UISearchBarDelegate {
  
  @Injected private var repository: DataRepository

  var image: UIImage!
  var cropRect: CGRect!
  var imageView: UIImageView!
  var loadingHud: JGProgressHUD!
  var scrollView: UIScrollView!
  var tableView: UITableView!
  var searchController: UISearchController = UISearchController()
  var taggedBusinessID: String?

  var foodStars: CosmosView!
  var serviceStars: CosmosView!
  var atmosphereStars: CosmosView!
  var valueStars: CosmosView!
  
  var tags: [String]!
  var tagObjects: [ReviewTag]!
  var textView: UITextView!
  static let postNotification = Notification.Name("post review")

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = NSLocalizedString("Posting", comment: "")
    
    NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: PostViewController.postNotification, object: nil)

    loadingHud = JGProgressHUD()
    loadingHud.textLabel.text = "Posting..."
    
    let scrollView = UIScrollView(frame: view.frame)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = false
    scrollView.isScrollEnabled = true
    scrollView.canCancelContentTouches = false
    view.addSubview(scrollView)
    scrollView.contentSize = view.bounds.size
    
//    let restaurantLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//    restaurantLabel.text = "Somewhere over the rainbow"
//    restaurantLabel.translatesAutoresizingMaskIntoConstraints = false
//    stackView.addArrangedSubview(restaurantLabel)
    
    let thumbnailPic = image.getThumbnail()
    let imageView = UIImageView(image: thumbnailPic)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.layer.shadowColor = UIColor.systemPink.cgColor
    imageView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    imageView.layer.shadowOpacity = 0.4
    imageView.layer.shadowRadius = 32
    scrollView.addSubview(imageView)
    
    let ratingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    ratingLabel.text = "What do you think of this experience?"
    ratingLabel.textColor = .systemPink
    ratingLabel.translatesAutoresizingMaskIntoConstraints = false
    ratingLabel.font = UIFont(name: "Helvetica Neue Medium", size: 18)
    scrollView.addSubview(ratingLabel)
    
    let stackView = UIStackView(frame: scrollView.bounds)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalCentering
    stackView.spacing = 4

    scrollView.addSubview(stackView)
    
    // Restaurant
//    let restaurantButton = UIButton(type: .custom)
//    restaurantButton.setTitle("Add Location", for: .normal)
//    restaurantButton.addTarget(self, action: #selector(tagBusiness), for: .touchUpInside)
//    stackView.addArrangedSubview(restaurantButton)
    
    
    // Food
    let foodLabel = UILabel()
    foodLabel.text = "Food"
    foodLabel.font = UIFont(name: "Helvetica Neue", size: 16)
    stackView.addArrangedSubview(foodLabel)
    
    self.foodStars = CosmosView()
    foodStars.rating = 0
    foodStars.settings.filledImage = UIImage(named: "star.fill")
    foodStars.settings.emptyImage = UIImage(named: "star")
    
    foodStars.settings.starSize = 40
    foodStars.settings.starMargin = 4
    foodStars.settings.fillMode = .half
    
    stackView.addArrangedSubview(foodStars)
    
    // Service
    let serviceLabel = UILabel()
    serviceLabel.text = "Service"
    serviceLabel.font = UIFont(name: "Helvetica Neue", size: 16)
    stackView.addArrangedSubview(serviceLabel)
    
    self.serviceStars = CosmosView()
    serviceStars.rating = 0
    serviceStars.settings.filledImage = UIImage(named: "star.fill")
    serviceStars.settings.emptyImage = UIImage(named: "star")
    
    serviceStars.settings.starSize = 40
    serviceStars.settings.starMargin = 4
    serviceStars.settings.fillMode = .half
  
    stackView.addArrangedSubview(serviceStars)
    
    // Atmosphere
    let atmosLabel = UILabel()
    atmosLabel.text = "Atmosphere"
    atmosLabel.font = UIFont(name: "Helvetica Neue", size: 16)
    stackView.addArrangedSubview(atmosLabel)
    
    self.atmosphereStars = CosmosView()
    atmosphereStars.rating = 0
    atmosphereStars.settings.filledImage = UIImage(named: "star.fill")
    atmosphereStars.settings.emptyImage = UIImage(named: "star")
    
    atmosphereStars.settings.starSize = 40
    atmosphereStars.settings.starMargin = 4
    atmosphereStars.settings.fillMode = .half
    
    stackView.addArrangedSubview(atmosphereStars)
    
    // Value
    let valueLabel = UILabel()
    valueLabel.text = "Value"
    valueLabel.font = UIFont(name: "Helvetica Neue", size: 16)
    stackView.addArrangedSubview(valueLabel)
    
    self.valueStars = CosmosView()
    valueStars.rating = 0
    valueStars.settings.filledImage = UIImage(named: "star.fill")
    valueStars.settings.emptyImage = UIImage(named: "star")
    
    valueStars.settings.starSize = 40
    valueStars.settings.starMargin = 4
    valueStars.settings.fillMode = .half
    
    stackView.addArrangedSubview(valueStars)

    self.textView = UITextView(frame: CGRect(x: 0, y: 0, width: 300, height: 140))
    textView.font = UIFont.systemFont(ofSize: 20)
    textView.autocorrectionType = .no
    textView.keyboardType = .default
    textView.returnKeyType = .done
    textView.layer.borderWidth = 1.5
    textView.layer.borderColor = UIColor.systemPink.cgColor
    textView.layer.cornerRadius = 10
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    textView.isScrollEnabled = false
    textView.textAlignment = .natural
    textView.text = "Additional comment goes here.."
    textView.textColor = UIColor.lightGray
    textView.delegate = self
    textView.layer.shadowColor = UIColor.systemPink.cgColor
    textView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
    textView.layer.shadowOpacity = 0.4
    textView.layer.shadowRadius = 20
    stackView.addArrangedSubview(textView)
    stackView.setCustomSpacing(32, after: textView)
    

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Post", style: .plain,
      target: self,
      action: #selector(uploadImage)
    )

//    let tagTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToTag))
//    imageView.isUserInteractionEnabled = true
//    imageView.addGestureRecognizer(tagTapGestureRecognizer)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
      imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
      imageView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
      
      ratingLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
      ratingLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
      
      stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 100),
      stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
      stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      stackView.widthAnchor.constraint(equalToConstant: 300),
      stackView.heightAnchor.constraint(equalToConstant: 800),

    ])
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.systemPink
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Additional comment goes here.."
      textView.textColor = UIColor.lightGray
    }
  }
  
//  @objc func tagBusiness() {
//    let businessTagVC = ResultTableController()
//    let navigationController = UINavigationController(rootViewController: businessTagVC)
//    navigationController.modalPresentationStyle = .formSheet
//    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    present(navigationController, animated: true, completion: nil)
//  }
  
  @objc func onNotification(notification: Notification) {
    print("post noti")
  }
  
  @objc func uploadImage() {
    loadingHud.show(in: view)
//    guard let description = textView.text else { return }
    if textView.text == "Additional comment goes here.." {
      textView.text = nil
    }
    repository.uploadPost(image: image, description: nil, businessId: taggedBusinessID!, foodRating: foodStars.rating, serviceRating: serviceStars.rating, atmosphereRating: atmosphereStars.rating, valueRating: valueStars.rating, tags: tags, tagObjects: tagObjects, additionalComment: textView.text)
    
    NotificationCenter.default.post(name: PostViewController.postNotification, object: self)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      // posting done
      self.loadingHud.dismiss(animated: true)
      self.navigationController?.popToRootViewController(animated: true)
      NotificationCenter.default.removeObserver(self)
    }
  }

//  @objc func tapToTag(_ gestureRecognizer: UIGestureRecognizer) {
//    if gestureRecognizer.state == .recognized {
//      let tappedView = gestureRecognizer.view!
//      let touchPoint = gestureRecognizer.location(in: scrollView)
//      let tagImageViewSize = CGSize(width: 32, height: 32)
//
//      if !(tappedView.bounds
//            .insetBy(dx: tagImageViewSize.width / 2, dy: tagImageViewSize.height / 2)
//            .contains(touchPoint))
//      {
//        // pad the tappedView by width / 2 to prevent image overflowing
//        _ = tappedView.bounds.insetBy(dx: tagImageViewSize.width / 2, dy: tagImageViewSize.height / 2)
////        return
//      }
//
//      let tagImageView = UIImageView(image: UIImage(named: "logo"))
//      tagImageView.frame = CGRect(origin: touchPoint, size: tagImageViewSize)
//      tagImageView.center = touchPoint
//
//      let tag = ReviewTag(x: touchPoint.x, y: touchPoint.y, description: "")
//      tags.append(tag)
//      gestureRecognizer.view?.addSubview(tagImageView)
//    }
//  }
}
    
extension UIImage {

  func getThumbnail() -> UIImage? {

    guard let imageData = self.pngData() else { return nil }

    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary

    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
    guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

    return UIImage(cgImage: imageReference)

  }
}
