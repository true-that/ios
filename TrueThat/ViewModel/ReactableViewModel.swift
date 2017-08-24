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
    updateInfo()
    updateReactionCounters()
  }
  
  /// Updates displayed info about the reactable.
  fileprivate func updateInfo() {
    if let displayName = model.director?.displayName {
      directorName.value = displayName
    }
    if model.created != nil {
      timeAgo.value = DateHelper.truncatedTimeAgo(from: model.created!)
    }
  }
  
  fileprivate func updateReactionCounters() {
    if model.reactionCounters != nil {
      let totalReactions = Array(model.reactionCounters!.values).reduce(0, +)
      if totalReactions == 0 {
        reactionsCount.value = ""
        reactionEmoji.value = ""
      } else {
        reactionsCount.value = NumberHelper.truncate(totalReactions)
        // If user already reacted use this emoji, otherwise use the most common one.
        if model.userReaction != nil {
          reactionEmoji.value = model.userReaction!.emoji
        } else if model.reactionCounters!.count > 0 {
          reactionEmoji.value = model.reactionCounters!.max{$0.0.value < $0.1.value}!.key.emoji
        }
      }
    } else {
      reactionsCount.value = ""
      reactionEmoji.value = ""
    }
  }
  
  /// - Parameter reactable: to create a view model from.
  /// - Returns: the proper view model based on `reactable` type.
  static func instantiate(with reactable: Reactable) -> ReactableViewModel {
    switch reactable {
    case is Pose:
      return PoseViewModel(with: reactable)
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
        timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
        eventType: .reactableView, reactableId: model.id))
        .on(value: {value in
          self.model.viewed = true
        })
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
    App.detecionModule.delegate = nil
    if (model.canReact(user: App.authModule.current!)) {
      InteractionApi.save(interaction: InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: reaction,
        eventType: .reactableReaction, reactableId: model.id))
        .on(value: {event in
          self.model.userReaction = reaction
          self.model.updateReactionCounters(with: reaction)
          self.updateReactionCounters()
        })
        .on(failed: {error in
          print(error)
        })
        .start()
    }
  }
}
