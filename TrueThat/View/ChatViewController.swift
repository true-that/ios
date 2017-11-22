//
//  ChatViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class ChatViewController: BaseChatViewController {

  static func instantiate(_ convo: Conversation) -> ChatViewController {
    let chatViewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ChatScene") as! ChatViewController
    let dataSource = FakeDataSource(count: 2, pageSize: 50)
    chatViewController.dataSource = dataSource
    chatViewController.messageSender = dataSource.messageSender
    return chatViewController
  }

  var messageSender: FakeMessageSender!
  var dataSource: FakeDataSource! {
    didSet {
      self.chatDataSource = self.dataSource
    }
  }

  lazy private var baseMessageHandler: BaseMessageHandler = {
    return BaseMessageHandler(messageSender: self.messageSender)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    let image = UIImage(named: "bubble-incoming-message")?.bma_tintWithColor(.blue)
    super.chatItemsDecorator = ChatItemsDemoDecorator()
    let addIncomingMessageButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(ChatViewController.addRandomIncomingMessage))
    self.navigationItem.rightBarButtonItem = addIncomingMessageButton
  }

  @objc
  private func addRandomIncomingMessage() {
    self.dataSource.addRandomIncomingMessage()
  }

  var chatInputPresenter: BasicChatInputBarPresenter!
  override func createChatInputView() -> UIView {
    let chatInputView = ChatInputBar.loadNib()
    var appearance = ChatInputBarAppearance()
    appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
    appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
    self.chatInputPresenter = BasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
    chatInputView.maxCharactersCount = 1000
    return chatInputView
  }

  override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {

    let textMessagePresenter = TextMessagePresenterBuilder(
      viewModelBuilder: DemoTextMessageViewModelBuilder(),
      interactionHandler: DemoTextMessageHandler(baseHandler: self.baseMessageHandler)
    )
    textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellAvatarStyle()

    let photoMessagePresenter = PhotoMessagePresenterBuilder(
      viewModelBuilder: DemoPhotoMessageViewModelBuilder(),
      interactionHandler: DemoPhotoMessageHandler(baseHandler: self.baseMessageHandler)
    )
    photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()

    return [
      DemoTextMessageModel.chatItemType: [
        textMessagePresenter
      ],
      DemoPhotoMessageModel.chatItemType: [
        photoMessagePresenter
      ],
      SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
      TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()]
    ]
  }

  func createChatInputItems() -> [ChatInputItemProtocol] {
    var items = [ChatInputItemProtocol]()
    items.append(self.createTextInputItem())
    items.append(self.createPhotoInputItem())
    return items
  }

  private func createTextInputItem() -> TextChatInputItem {
    let item = TextChatInputItem()
    item.textInputHandler = { [weak self] text in
      self?.dataSource.addTextMessage(text)
    }
    return item
  }

  private func createPhotoInputItem() -> PhotosChatInputItem {
    let item = PhotosChatInputItem(presentingController: self)
    item.photoInputHandler = { [weak self] image in
      self?.dataSource.addPhotoMessage(image)
    }
    return item
  }
}
