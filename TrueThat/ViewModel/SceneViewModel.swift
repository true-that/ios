//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class SceneViewModel {
  public static let reportTitle = "Reported! 👮🏻"
  public static let reportOkText = "got it"
  public static let reportAlert = "Thank you for your alertness."
  // MARK: Properties
  public let directorName = MutableProperty("")
  public let timeAgo = MutableProperty("")
  public let reactionEmoji = MutableProperty("")
  public let reactionsCount = MutableProperty("")
  public let loadingImageHidden = MutableProperty(false)
  public let optionsButtonHidden = MutableProperty(true)
  public let reportHidden = MutableProperty(true)
  
  var model: Scene
  var delegate: SceneViewDelegate!
  
  // MARK: Initialization
  init(with scene: Scene) {
    model = scene
    updateInfo()
    updateReactionCounters()
  }
  
  /// Updates displayed info about the scene.
  fileprivate func updateInfo() {
    if let displayName = model.director?.displayName {
      directorName.value = displayName
    }
    if model.created != nil {
      timeAgo.value = DateHelper.truncatedTimeAgo(from: model.created!)
    }
  }
  
  /// Aggregates and truncates the reaction counters and sets a proper emoji icon.
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
  
  // Mark: Actions
  public func didReport() {
    reportHidden.value = true
    if model.viewed == nil || !model.viewed! {
      App.log.warning("Tried to report a scene before viewing it.")
      return
    }
    let event = InteractionEvent(
      timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
      eventType: .report, sceneId: model.id)
    InteractionApi.save(interaction: event)
      .on(value: {value in
        App.log.debug("Interaction event successfully saved.")
        self.delegate?.show(alert: SceneViewModel.reportAlert,
                            withTitle: SceneViewModel.reportTitle,
                            okAction: SceneViewModel.reportOkText)
      })
      .on(failed: {error in
        App.log.report(
          "Could not save interaction event \(event) becuase of \(error)",
          withError: error)
      })
      .start()
  }
  
  // MARK: Lifecycle
  
  /// Triggered when its corresponding {SceneViewController} is disappeared.
  public func didDisappear() {
    if (App.detecionModule.delegate is SceneViewModel &&
      App.detecionModule.delegate as! SceneViewModel === self) {
      App.detecionModule.delegate = nil
    }
    optionsButtonHidden.value = true
    reportHidden.value = true
  }
  
  /// Triggered when the media of {model} is downloaded and displayed.
  public func didDisplay() {
    App.log.debug("didDisplay")
    // Show options button
    optionsButtonHidden.value = false
    // Hide loading image
    loadingImageHidden.value = true
    // Send view event if needed
    if model.viewed != true {
      self.model.viewed = true
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
        eventType: .view, sceneId: model.id)
      InteractionApi.save(interaction: event)
        .on(value: {value in
          App.log.debug("Interaction event successfully saved.")
        })
        .on(failed: {error in
          App.log.report(
            "Could not save interaction event \(event) becuase of \(error)",
            withError: error)
        })
        .start()
    }
    // Sets the detection delegate to this scene.
    App.detecionModule.delegate = self
  }
}

// MARK: ReactionDetectionDelegate
extension SceneViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion) {
    App.detecionModule.delegate = nil
    if (model.canReact(user: App.authModule.current!)) {
      model.userReaction = reaction
      model.updateReactionCounters(with: reaction)
      updateReactionCounters()
      delegate.animateReactionImage()
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: reaction,
        eventType: .reaction, sceneId: model.id)
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

protocol SceneViewDelegate {
  
  /// Animates emotional reation image, so that the user see his reaction was captured.
  func animateReactionImage()
  
  /// Shows `alert` to the user, to inform him of errors and warnings.
  ///
  /// - Parameters:
  ///   - alert: message body of alert
  ///   - withTitle: title at the top of the dislogue
  ///   - okAction: what the user clicks to terminate the dialogue
  func show(alert: String, withTitle: String, okAction: String)
}
