//
//  ResultTableController.swift
//  ResultTableController
//
//  Created by itsnk on 8/28/21.
//

import Foundation
import UIKit
import Resolver
import FirebaseFirestore

protocol ResultTableControllerDelegate {
  func didFinishChoosing(controller: ResultTableController)
}

class ResultTableController: UIViewController {
  
  @Injected private var repository: DataRepository
  
  var delegate: ResultTableControllerDelegate! = nil
  
  var chosenBusinessName: String?
  
  var chosenRow: Int?
  
  var filteredBusiness = [Business]()
  
  var businessDictionary = [Int:String]()
  
  lazy var searchController: UISearchController = {
    let s = UISearchController(searchResultsController: nil)
//    s.searchResultsUpdater = self
    s.obscuresBackgroundDuringPresentation = true
    s.searchBar.placeholder = "Search location.."
    s.searchBar.sizeToFit()
    s.searchBar.searchBarStyle = .prominent
    s.searchBar.delegate = self
    return s
  }()
  
  override func viewDidLoad() {
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.delegate = self
    tv.dataSource = self
    tv.register(BusinessCell.self, forCellReuseIdentifier: "business")
    tv.tableFooterView = UIView(frame: CGRect.zero)
    view.addSubview(tv)
    
    navigationItem.searchController = searchController
    navigationItem.searchController?.isActive = true
    
    NSLayoutConstraint.activate([
      tv.topAnchor.constraint(equalTo: view.topAnchor),
      tv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tv.leftAnchor.constraint(equalTo: view.leftAnchor),
      tv.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil, userInfo: nil)
    print("sent refresh noti")
  }
}

extension ResultTableController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repository.getTotalBusinessCount()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "business", for: indexPath) as? BusinessCell
    else {
      let c = UITableViewCell()
      c.isHidden = true
      return c }
    cell.nameLabel.text = repository.businesses[indexPath.row].name
    cell.addressLabel.text = repository.businesses[indexPath.row].address
    businessDictionary[indexPath.row] = repository.businesses[indexPath.row].id
    cell.separatorInset.left = -8
    cell.separatorInset.right = 0
    cell.heightAnchor.constraint(equalToConstant: 42).isActive = true
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.chosenRow = indexPath.row
    let c = tableView.cellForRow(at: indexPath) as! BusinessCell
    chosenBusinessName = c.nameLabel.text
    delegate.didFinishChoosing(controller: self)
    navigationController?.popViewController(animated: true)
  }
}

extension ResultTableController: UISearchBarDelegate {
//  func updateSearchResults(for searchController: UISearchController) {
//    <#code#>
//  }
//
//  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//    <#code#>
//  }
}

class BusinessCell: UITableViewCell {
  
  let nameLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 16)
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.frame = CGRect(x: 0, y: 0, width: 270, height: 21)
    return lbl
  }()
  
  let addressLabel: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .left
    lbl.font = UIFont.systemFont(ofSize: 10, weight: .light)
    return lbl
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(nameLabel)
    addSubview(addressLabel)
    
    NSLayoutConstraint.activate([
      nameLabel.topAnchor.constraint(equalTo: topAnchor),
      nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
      nameLabel.rightAnchor.constraint(equalTo: addressLabel.leftAnchor, constant: 4),
      nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      nameLabel.widthAnchor.constraint(equalToConstant: 270),
      
      addressLabel.topAnchor.constraint(equalTo: topAnchor),
      addressLabel.widthAnchor.constraint(equalToConstant: 180),
      addressLabel.rightAnchor.constraint(equalTo: rightAnchor),
      addressLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
