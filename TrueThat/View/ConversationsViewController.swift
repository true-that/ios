//
//  ConversationsViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import SendBirdSDK

class ConversationsViewController: UITableViewController {
  var viewModel: ConversationsViewModel!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //    self.navigationItem.rightBarButtonItem = newConvoButton

    if viewModel == nil {
      viewModel = ConversationsViewModel()
      viewModel.delegate = self
    }

    SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.didAppear()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.conversations.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)

//    if viewModel.conversations[indexPath.row].title != nil {
//      cell.textLabel?.text = viewModel.conversations[indexPath.row].title
//    }
//    cell.detailTextLabel?.text = "conversation preview"

    cell.textLabel?.text = "row \(indexPath.row)"

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatViewController = ChatViewController.instantiate(viewModel.conversations[indexPath.row])
    navigationController?.pushViewController(chatViewController, animated: true)
  }
}

// MARK: ConversationsViewModel
extension ConversationsViewController: ConversationsViewModelDelegate {
  func add(conversations: [Conversation]) {
    tableView.beginUpdates()
    tableView.insertRows(at: [IndexPath(row: viewModel.conversations.count-1, section: 0)], with: .automatic)
    tableView.endUpdates()
  }
}

// MARK: SBDConnectionDelegate
extension ConversationsViewController: SBDConnectionDelegate {
  func didFailReconnection() {

  }

  func didStartReconnection() {

  }

  func didCancelReconnection() {

  }

  func didSucceedReconnection() {

  }
}
