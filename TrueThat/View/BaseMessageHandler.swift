//
//  BaseMessageHandler.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

public protocol DemoMessageViewModelProtocol {
  var messageModel: DemoMessageModelProtocol { get }
}

class BaseMessageHandler {

  private let messageSender: FakeMessageSender
  init (messageSender: FakeMessageSender) {
    self.messageSender = messageSender
  }
  func userDidTapOnFailIcon(viewModel: DemoMessageViewModelProtocol) {
    print("userDidTapOnFailIcon")
    self.messageSender.sendMessage(viewModel.messageModel)
  }

  func userDidTapOnAvatar(viewModel: MessageViewModelProtocol) {
    print("userDidTapOnAvatar")
  }

  func userDidTapOnBubble(viewModel: DemoMessageViewModelProtocol) {
    print("userDidTapOnBubble")
  }

  func userDidBeginLongPressOnBubble(viewModel: DemoMessageViewModelProtocol) {
    print("userDidBeginLongPressOnBubble")
  }

  func userDidEndLongPressOnBubble(viewModel: DemoMessageViewModelProtocol) {
    print("userDidEndLongPressOnBubble")
  }
}
