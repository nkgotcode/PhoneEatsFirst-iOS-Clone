//
//  CommentViewController.swift
//  CommentViewController
//
//  Created by itsnk on 9/9/21.
//

import Foundation
import UIKit
import Resolver

class CommentViewController: UIViewController {
  @Injected private var repository: DataRepository
  var review: Review!
  var comments: [Comment]!
  var commentField: UITextField!
  var commentBtn: UIButton!
  // This constraint ties an element at zero points from the bottom layout guide
   @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.comments = repository.getComments(commentIDs: review.comments)
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.delegate = self
    tv.dataSource = self
    tv.register(CommentCell.self, forCellReuseIdentifier: "comment")
    tv.tableFooterView = UIView(frame: .zero)
    tv.isUserInteractionEnabled = false
    tv.isScrollEnabled = true
    view.addSubview(tv)
    
    commentBtn = UIButton()
    commentBtn.setImage(UIImage(systemName: "arrow.up.circle"), for: .normal)
    commentBtn.tintColor = .systemPink
    commentBtn.contentMode = .scaleAspectFit
    commentBtn.translatesAutoresizingMaskIntoConstraints = false
    
    commentField = CustomCommentField()
    commentField.placeholder = "Leave a comment.."
    commentField.layer.borderColor = UIColor.systemPink.cgColor
    commentField.layer.borderWidth = 3
    commentField.layer.cornerRadius = 10
    commentField.layer.masksToBounds = true
    commentField.textAlignment = .left
    commentField.textColor = .systemPink
    commentField.delegate = self
    commentField.translatesAutoresizingMaskIntoConstraints = false
    
    let commentTable = UITableViewCell()
    commentTable.selectionStyle = .none
    commentTable.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(commentTable)
    commentTable.addSubview(commentField)
    commentTable.addSubview(commentBtn)
    
    let scrollGesture = UIGestureRecognizer(target: self, action: #selector(hideKeyboardScroll))
    view.addGestureRecognizer(scrollGesture)
    
    NSLayoutConstraint.activate([
      tv.topAnchor.constraint(equalTo: view.topAnchor),
      tv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      
      commentTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      commentTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
      commentTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      commentTable.heightAnchor.constraint(equalToConstant: 50),
      
      commentField.topAnchor.constraint(equalTo: commentTable.topAnchor),
      commentField.bottomAnchor.constraint(equalTo: commentTable.bottomAnchor),
      commentField.leadingAnchor.constraint(equalTo: commentTable.leadingAnchor),
      commentField.trailingAnchor.constraint(equalTo: commentBtn.leadingAnchor),
      
      commentBtn.topAnchor.constraint(equalTo: commentTable.topAnchor),
      commentBtn.bottomAnchor.constraint(equalTo: commentTable.bottomAnchor),
      commentBtn.trailingAnchor.constraint(equalTo: commentTable.trailingAnchor),
      commentBtn.widthAnchor.constraint(equalToConstant: 50)
      
    ])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    commentField.textRect(forBounds: commentField.bounds)
    commentField.editingRect(forBounds: commentField.bounds)
    commentField.becomeFirstResponder()
    NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.showKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
  }
  
  @objc func hideKeyboardScroll() {
    commentField.resignFirstResponder()
  }
  
  @objc func showKeyboardNotification(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }

     let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
     let endFrameY = endFrame?.origin.y ?? 0
     let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
     let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
     let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
     let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

     if endFrameY >= UIScreen.main.bounds.size.height {
       self.keyboardHeightLayoutConstraint?.constant = 0.0
     } else {
       self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
     }

     UIView.animate(
       withDuration: duration,
       delay: TimeInterval(0),
       options: animationCurve,
       animations: { self.view.layoutIfNeeded() },
       completion: nil)
  }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return review.comments.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as? CommentCell
    else {
      let c = UITableViewCell()
      c.isHidden = true
      return c
    }
    
    // first row for user's review
    if indexPath.row == 0 {
      let reviewUser = repository.getUser(id: review.userId)
      cell.userLabel.text = reviewUser?.username
      cell.comment.text = review.additionalComment
      cell.timestamp.text = repository.getDisplayTimestamp(creationDate: review.creationDate!)
      cell.profileImageView.sd_setImage(with: URL(string: (reviewUser?.profileImageUrl)!), completed: { [self]
         downloadedImage, error, cacheType, url in
         if let error = error {
           print("error downloading image: \(error.localizedDescription)")
           cell.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate)
         }
         else {
           print("successfully downloaded: \(String(describing: url))")
           cell.profileImageView.image = downloadedImage!
         }
      })
    } else { // rest of table for comments
      let commentUser = repository.getUser(id: comments[indexPath.row - 1].id!)
      cell.userLabel.text = commentUser?.username
      cell.comment.text = comments[indexPath.row - 1].comment
      cell.timestamp.text = repository.getDisplayTimestamp(creationDate: comments[indexPath.row - 1].creationDate!)
      cell.profileImageView.sd_setImage(with: URL(string: (commentUser?.profileImageUrl)!), completed: { [self]
         downloadedImage, error, cacheType, url in
         if let error = error {
           print("error downloading image: \(error.localizedDescription)")
           cell.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate)
         }
         else {
           print("successfully downloaded: \(String(describing: url))")
           cell.profileImageView.image = downloadedImage!
         }
      })
    }
    return cell
  }
  
  
}

class CommentCell: UITableViewCell {
  var profileImageView: UIImageView = {
    let imgView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")!.withTintColor(.systemPink, renderingMode: .alwaysTemplate))
    imgView.translatesAutoresizingMaskIntoConstraints = false
    return imgView
  }()
  
  var userLabel: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return lbl
  }()
  
  let comment: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 14)
    return lbl
  }()
  let timestamp: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 12, weight: .light)
    return lbl
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(profileImageView)
    addSubview(userLabel)
    addSubview(comment)
    addSubview(timestamp)
    
    NSLayoutConstraint.activate([
      profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      profileImageView.widthAnchor.constraint(equalToConstant: 40),
      profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
      
      userLabel.topAnchor.constraint(equalTo: topAnchor),
      userLabel.bottomAnchor.constraint(equalTo: comment.topAnchor),
      userLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      
      comment.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      
      timestamp.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      timestamp.topAnchor.constraint(equalTo: comment.bottomAnchor, constant: 4),
      timestamp.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CommentViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.text == "" {
      return
    } else {
      let commentID = repository.firestore.collection(repository.commentPath).document(review.id!).documentID
      let comment = Comment(id: commentID, comment: textField.text!, uid: repository.user!.id, creationDate: nil)
      repository.uploadComment(comment: comment, review: review)
    }
  }
}

class CustomCommentField: UITextField {
  // placeholder position
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 10, dy: 10)
  }
  // text position
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 10, dy: 10);
  }
  
}
