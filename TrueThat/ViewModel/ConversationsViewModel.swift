//
//  ConversationsViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import SendBirdSDK

class ConversationsViewModel {
  var delegate: ConversationsViewModelDelegate!
  var conversations: [Conversation] = []

  // MARK: Lifecycle
  func didAppear() {
    conversations += [Conversation(id: nil)]
    delegate.add(conversations: [Conversation(id: nil)])
  }
}

protocol ConversationsViewModelDelegate {
  func add(conversations: [Conversation])
}
