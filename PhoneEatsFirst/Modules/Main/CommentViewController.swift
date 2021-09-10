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
  
  override func viewDidLoad() {
    self.comments = repository.getComments(commentIDs: review.comments)
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.delegate = self
    tv.dataSource = self
    tv.register(CommentCell.self, forCellReuseIdentifier: "comment")
    tv.tableFooterView = UIView(frame: .zero)
    tv.isUserInteractionEnabled = false
    view.addSubview(tv)
    
    NSLayoutConstraint.activate([
      tv.topAnchor.constraint(equalTo: view.topAnchor),
      tv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    ])
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
      
      
      comment.bottomAnchor.constraint(equalTo: timestamp.topAnchor),
      comment.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      
      timestamp.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      timestamp.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
