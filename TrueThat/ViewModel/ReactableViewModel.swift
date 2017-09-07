//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ReactableViewModel {
  // MARK: Properties
  public let directorName = MutableProperty("")
  public let timeAgo = MutableProperty("")
  public let reactionEmoji = MutableProperty("")
  public let reactionsCount = MutableProperty("")
  public let loadingImageHidden = MutableProperty(false)
  
  var model: Reactable
  var delegate: ReactableViewDelegate!
  
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
  
  // MARK: Lifecycle
  /// Triggered when its corresponding {ReactableViewController} is disappeared.
  public func didDisappear() {
    if (App.detecionModule.delegate is ReactableViewModel &&
      App.detecionModule.delegate as! ReactableViewModel === self) {
      App.detecionModule.delegate = nil
    }
  }
  
  /// Triggered when the media of {model} is downloaded and displayed.
  public func didDisplay() {
    loadingImageHidden.value = true
    if model.viewed != true {
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
        eventType: .view, reactableId: model.id)
      InteractionApi.save(interaction: event)
        .on(value: {value in
          self.model.viewed = true
        })
        .on(failed: {error in
          App.log.report(
            "Could not save interaction event \(event) becuase of \(error)",
            withError: error)
        })
        .start()
    }
    // Sets the detection delegate to this reactable.
    App.detecionModule.delegate = self
  }
}

// MARK: ReactionDetectionDelegate
extension ReactableViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion) {
    App.detecionModule.delegate = nil
    if (model.canReact(user: App.authModule.current!)) {
      model.userReaction = reaction
      model.updateReactionCounters(with: reaction)
      updateReactionCounters()
      delegate.animateReactionImage()
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: reaction,
        eventType: .reaction, reactableId: model.id)
      InteractionApi.save(interaction: event)
        .on(value: {value in
          App.log.debug("Interaction event successfully saved.")
        })
        .on(failed: {error in
          App.log.report("Could not save interaction event \(event) becuase of \(error)",
            withError: error)
        })
        .start()
    }
  }
}

protocol ReactableViewDelegate {
  
  /// Animates emotional reation image, so that the user see his reaction was captured.
  func animateReactionImage()
}
