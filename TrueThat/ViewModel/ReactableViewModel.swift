//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ReactableViewModel {
  public let directorName = MutableProperty("")
  public let timeAgo = MutableProperty("")
  public let reactionEmoji = MutableProperty("")
  public let reactionsCount = MutableProperty("")
  
  var model: Reactable
  
  /// As the type is determined in run time, we keet at as `Any`.
  var delegate: Any!
  
  // MARK: Initialization
  init(with reactable: Reactable) {
    model = reactable
    if let displayName = model.director?.displayName {
      directorName.value = displayName
    }
    if model.created != nil {
      timeAgo.value = DateHelper.truncatedTimeAgo(from: model.created!)
    }
    if model.reactionCounters != nil {
      reactionsCount.value = NumberHelper.truncate(Array(model.reactionCounters!.values).reduce(0, +))
      // If user already reacted use this emoji, otherwise use the most common one.
      if model.userReaction != nil {
        reactionEmoji.value = model.userReaction!.emoji
      } else {
        reactionEmoji.value = model.reactionCounters!.max{$0.0.value < $0.1.value}!.key.emoji
      }
    }
  }
  
  /// - Parameter reactable: to create a view model from.
  /// - Returns: the proper view model based on `reactable` type.
  static func instantiate(with reactable: Reactable) -> ReactableViewModel {
    switch reactable {
    case is Scene:
      return SceneViewModel(with: reactable)
    default:
      return ReactableViewModel(with: reactable)
    }
  }
  
  // MARK: Lifecycle
  
  /// Triggered when its corresponding {ReactableViewController} is loaded.
  public func didLoad() {}
  
  /// Triggered when its corresponding {ReactableViewController} is disappeared.
  public func didDisappear() {
    if (App.detecionModule.delegate is ReactableViewModel &&
        App.detecionModule.delegate as! ReactableViewModel === self) {
      App.detecionModule.delegate = nil
    }
  }
  
  /// Triggered when the media of {model} is downloaded and displayed.
  public func didDisplay() {
    if model.viewed != true {
      InteractionApi.save(interaction: InteractionEvent(
        timestamp: Date(), userId: App.authModule.currentUser.id, reaction: nil,
        eventType: .view, reactableId: model.id))
        .on(failed: {error in
          print(error)
        })
        .start()
    }
    // Sets the detection delegate to this reactable.
    App.detecionModule.delegate = self
  }
}

extension ReactableViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion) {
    if (model.canReact(user: App.authModule.currentUser)) {
      InteractionApi.save(interaction: InteractionEvent(
        timestamp: Date(), userId: App.authModule.currentUser.id, reaction: reaction,
        eventType: .reaction, reactableId: model.id))
        .on(value: {event in
          self.model.userReaction = reaction
        })
        .on(failed: {error in
          print(error)
        })
        .start()
    }
  }
}
