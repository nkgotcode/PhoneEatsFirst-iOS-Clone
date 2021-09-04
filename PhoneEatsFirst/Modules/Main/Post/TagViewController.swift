//
//  TagViewController.swift
//  TagViewController
//
//  Created by itsnk on 8/25/21.
//

import Foundation
import UIKit
import CropViewController
import IQKeyboardManagerSwift

class TagViewController: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ResultTableControllerDelegate {

    private let imageView = UIImageView()
      
    var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default

    var searchBar: UISearchBar!
  
    var taggedBusinessID: String?
  
    var searchVC: ResultTableController?
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    var tags: [ReviewTag] = []
    private var isTagging : Bool = true
    
    @IBOutlet weak var commentText: UITextView!
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        imageView.image = image
        layoutImageView()
        
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            imageView.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: imageView,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: {
                                                    self.imageView.isHidden = false })
        }
        else {
            self.imageView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      
      title = NSLocalizedString("Comment Tagging", comment: "")
      navigationController!.navigationBar.isTranslucent = false
      navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
      navigationController?.navigationBar.shadowImage = UIImage()
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(doneButtonTapped(sender:)))
      
      self.searchBar = UISearchBar()
      searchBar.sizeToFit()
      searchBar.placeholder = "Search location.."
      navigationItem.titleView = searchBar
      let searchButton = UIButton(frame: searchBar.frame)
      searchButton.addTarget(self, action: #selector(pressedSearch), for: .touchUpInside)
      self.extendedLayoutIncludesOpaqueBars = true
      searchBar.addSubview(searchButton)
      
      // tagged location
//      locationLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
//      locationLabel.translatesAutoresizingMaskIntoConstraints = false
//      view.addSubview(locationLabel)
      
      
      imageView.image = image
      imageView.isUserInteractionEnabled = true
      imageView.contentMode = .scaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      if #available(iOS 11.0, *) {
          imageView.accessibilityIgnoresInvertColors = true
      }
      view.addSubview(imageView)
      
      let showingTagsButton = UIButton(type: UIButton.ButtonType.custom)
      showingTagsButton.setImage(UIImage(named: "tag.circle.fill"), for: .normal)
      showingTagsButton.addTarget(self, action: #selector(showingTags), for: .touchUpInside)
      showingTagsButton.translatesAutoresizingMaskIntoConstraints = false
      imageView.addSubview(showingTagsButton)
      
      let tagRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapToTag))
      imageView.addGestureRecognizer(tagRecognizer)
      
      let cancelCommentRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(cancelComment))
      view.addGestureRecognizer(cancelCommentRecognizer)
      
      NSLayoutConstraint.activate([
        showingTagsButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
        showingTagsButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        
//        locationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
//        locationLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 32),
//        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//        locationLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor)
      ])
    }
  
    override func viewWillDisappear(_ animated: Bool) {
      navigationController?.view.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @objc public func doneButtonTapped(sender: UIBarButtonItem) {
      let postVC = PostViewController()
      postVC.image = image
      postVC.taggedBusinessID = taggedBusinessID
      postVC.tags = tags
      self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc public func didTapImageView() {
        // When tapping the image view, restore the image to the previous cropping state
        let cropViewController = CropViewController(croppingStyle: self.croppingStyle, image: self.image!)
        cropViewController.delegate = self
        let viewFrame = view.convert(imageView.frame, to: navigationController!.view)

        cropViewController.presentAnimatedFrom(self,
                                               fromImage: self.imageView.image,
                                               fromView: nil,
                                               fromFrame: viewFrame,
                                               angle: self.croppedAngle,
                                               toImageFrame: self.croppedRect,
                                               setup: { self.imageView.isHidden = true },
                                               completion: nil)
      
    }
  
    @objc func tapToTag(_ gestureRecognizer: UIGestureRecognizer) {
      if gestureRecognizer.state == .recognized {
        let tappedView = gestureRecognizer.view!
        let touchPoint = gestureRecognizer.location(in: imageView)
        let tagImageViewSize = CGSize(width: 32, height: 32)

        if !(tappedView.bounds
              .insetBy(dx: tagImageViewSize.width / 2, dy: tagImageViewSize.height / 2)
              .contains(touchPoint))
        {
          // pad the tappedView by width / 2 to prevent image overflowing
//          _ = tappedView.bounds.insetBy(dx: tagImageViewSize.width / 2, dy: tagImageViewSize.height / 2)
            return
        }

        let tagImageView = UIImageView(image: UIImage(named: "logo"))
        tagImageView.frame = CGRect(origin: touchPoint, size: tagImageViewSize)
        tagImageView.center = touchPoint
        
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 32, height: 32)
        button.setImage(UIImage(named: "logo"), for: .normal)
        button.addTarget(self, action: #selector(commentTag), for: .touchUpInside)
        
        commentTag(sender: button)
        
        let tag = ReviewTag(x: touchPoint.x, y: touchPoint.y, description: "")
        tags.append(tag)
        gestureRecognizer.view?.addSubview(button)
      }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutImageView()
    }
    
    public func layoutImageView() {
        guard imageView.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = imageView.image!.size;
        
        if imageView.image!.size.width > viewFrame.size.width || imageView.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            imageView.frame = imageFrame
        }
        else {
            self.imageView.frame = imageFrame;
            self.imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
  
    @objc public func sharePhoto() {
        guard let image = imageView.image else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem!
        present(activityController, animated: true, completion: nil)
    }
  
    func didFinishChoosing(controller: ResultTableController) {
      DispatchQueue.main.async {
        self.taggedBusinessID = controller.businessDictionary[controller.chosenRow!]
        self.searchBar.searchTextField.leftView?.tintColor = .systemBackground
        self.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: controller.chosenBusinessName!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBackground])
        self.searchBar.searchTextField.backgroundColor = .systemPink
      }
    }
  
    @objc func showingTags(sender: UIButton) {
      self.isTagging.toggle()
      sender.setImage(UIImage(named: "tag.circle"), for: .normal)
      print("showing tags button pressed")
    }
  
    @objc func commentTag(sender: UIButton) {
      print("tapped tag")
//      sender.frame.origin.x
//      let buttonPos = sender.frame.origin
      let textFieldPos = CGPoint(x: sender.frame.maxX, y: sender.frame.maxY)
//      let textField = UITextField(frame: CGRect(origin: textFieldPos, size: CGSize.init(width: 200, height: 50)))
      let textView = UITextView(frame: CGRect(origin: textFieldPos, size: CGSize.init(width: 180, height: 80)))
      textView.textAlignment = .natural
      textView.layer.borderColor = UIColor.lightGray.cgColor
      textView.isScrollEnabled = true
      textView.font = UIFont.systemFont(ofSize: 14)
      textView.delegate = self
      imageView.addSubview(textView)
      imageView.isUserInteractionEnabled = false
      textView.becomeFirstResponder()
//      let editingTextRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(editingText))
//      textView.addGestureRecognizer(editingTextRecognizer)
    }
  
    @objc func cancelComment() {
      imageView.isUserInteractionEnabled = true
      print("cancel comment")
      UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
  
    func textViewDidChange(_ textView: UITextView) {
      imageView.isUserInteractionEnabled = false
      if textView.isFirstResponder {
        imageView.isUserInteractionEnabled = false
      }
      print(textView.text as Any)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
      imageView.isUserInteractionEnabled = false
      print("textViewDidBeginEditing")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
      imageView.isUserInteractionEnabled = false
      print("textViewDidBeginEditing")
    }
    
    @objc func pressedSearch() {
      self.searchVC = ResultTableController()
      self.searchVC!.delegate = self
      navigationController?.pushViewController(self.searchVC!, animated: true)
    }
}

extension UIView {
  func fadeIn() {
    UIView.animate(withDuration: 1, delay: 0, options: AnimationOptions.curveEaseIn, animations: {self.alpha = 1.0}, completion: nil)
  }
  
  func fadeOut() {
    UIView.animate(withDuration: 1, delay: 0, options: AnimationOptions.curveEaseOut, animations: {self.alpha = 1.0}, completion: nil)
  }
}


