//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class SceneViewModel {
  static var detetionDelaySeconds = 0.1
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

  /// The underlying data model
  var scene: Scene

  /// The UI delegate of this view model.
  var delegate: SceneViewDelegate!

  /// The media the user is currently viewing.
  var currentMedia: Media?

  /// The next media to display to the user. It is determined by his reaction to the current media.
  var nextMedia: Media?

  /// The last detected reaction.
  var lastReaction: Emotion?

  /// All detected reactions per displayed media.
  var detectedReactions: [Media: Set<Emotion>] = [:]

  /// Timer to delay reaction detection.
  var timer: Timer?

  /// Whether a media was viewed by the user.
  var mediaViewed: [Media: Bool] = [:]

  /// Maintains media state and whether it can be immediately displayed to the user.
  var mediaReady: [Media: Bool] = [:]

  // MARK: Initialization
  init(with scene: Scene) {
    self.scene = scene
    updateInfo()
    updateReactionCounters(with: nil)
  }

  // MARK: Methods
  /// Updates displayed info about the scene.
  fileprivate func updateInfo() {
    if let displayName = scene.director?.displayName {
      directorName.value = displayName
    }
    if scene.created != nil {
      timeAgo.value = DateHelper.truncatedTimeAgo(from: scene.created!)
    }
  }

  /// Aggregates and truncates the reaction counters and sets a proper emoji icon.
  ///
  /// - Parameter reaction: to enforce an emoji to display
  fileprivate func updateReactionCounters(with reaction: Emotion?) {
    if scene.reactionCounters != nil {
      let totalReactions = Array(scene.reactionCounters!.values).reduce(0, +)
      if totalReactions == 0 {
        reactionsCount.value = ""
        reactionEmoji.value = ""
      } else {
        reactionsCount.value = NumberHelper.truncate(totalReactions)
        // If a reaction is provided use it, otherwise use the most common one.
        if reaction != nil {
          reactionEmoji.value = reaction!.emoji
        } else if scene.reactionCounters!.count > 0 {
          reactionEmoji.value = scene.reactionCounters!.max { $0.0.value < $0.1.value }!.key.emoji
        }
      }
    } else {
      reactionsCount.value = ""
      reactionEmoji.value = ""
    }
  }

  func didReport() {
    App.log.debug("didReport")
    reportHidden.value = true
    if currentMedia == nil || mediaViewed[currentMedia!] == nil || !mediaViewed[currentMedia!]! {
      App.log.warning("Tried to report a scene before viewing it.")
      return
    }
    let event = InteractionEvent(
      timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
      eventType: .report, sceneId: scene.id, mediaId: currentMedia!.id)
    InteractionApi.save(interaction: event)
      .on(value: { _ in
        App.log.debug("Interaction event successfully saved.")
        self.delegate?.show(alert: SceneViewModel.reportAlert,
                            title: SceneViewModel.reportTitle,
                            okAction: SceneViewModel.reportOkText)
      })
      .on(failed: { error in
        App.log.report(
          "Could not save interaction event \(event) becuase of \(error)",
          withError: error)
      })
      .start()
  }

  /// Prepares `media` for display.
  ///
  /// - Parameter media: to display.
  func willDisplay(media: Media) {
    App.log.debug("willDisplay media with ID \(media.id!)")
    // Stops reaction detection temporarily until the new media is displayed.
    App.detecionModule.delegate = nil
    // Update state
    currentMedia = media
    nextMedia = nil
    if detectedReactions[currentMedia!] == nil {
      detectedReactions[currentMedia!] = []
    }
    if mediaViewed[currentMedia!] == nil {
      mediaViewed[currentMedia!] = false
    }
    if mediaReady[currentMedia!] == nil {
      mediaReady[currentMedia!] = false
    }
    lastReaction = nil
    // Performing the display
    delegate.display(media: media)
  }

  /// Triggered when the media of {scene} is downloaded and displayed.
  public func didDisplay() {
    App.log.debug("didDisplay")
    // Show options button
    optionsButtonHidden.value = false
    // Hide loading image
    loadingImageHidden.value = true
    // Send view event if needed
    if !mediaViewed[currentMedia!]! {
      mediaViewed[currentMedia!] = true
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: nil,
        eventType: .view, sceneId: scene.id, mediaId: currentMedia!.id)
      InteractionApi.save(interaction: event)
        .on(value: { _ in
          App.log.debug("Interaction event successfully saved.")
        })
        .on(failed: { error in
          App.log.report(
            "Could not save interaction event \(event) becuase of \(error)",
            withError: error)
        })
        .start()
    }
    // Sets the detection delegate to this scene.
    timer = Timer.scheduledTimer(withTimeInterval: SceneViewModel.detetionDelaySeconds, repeats: false,
                                 block: { _ in App.detecionModule.delegate = self })
  }

  // MARK: Lifecycle

  /// Triggered when its corresponding {SceneViewController} appears.
  func didAppear() {
    if currentMedia == nil {
      currentMedia = scene.rootMedia
    }
    guard currentMedia != nil else {
      return
    }
    willDisplay(media: currentMedia!)
  }

  /// Triggered when its corresponding {SceneViewController} is disappeared.
  func didDisappear() {
    if App.detecionModule.delegate is SceneViewModel &&
      App.detecionModule.delegate as! SceneViewModel === self {
      App.detecionModule.delegate = nil
    }
    optionsButtonHidden.value = true
    reportHidden.value = true
    timer?.invalidate()
    delegate.hideMedia()
  }
}

// MARK: ReactionDetectionDelegate
extension SceneViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion, mostLikely: Bool) {
    if currentMedia == nil {
      return
    }
//    // non most likely reactions are ignored when there are multiple next media options or the current reaction could
//    // not lead to a next media.
//    if !mostLikely && (scene.next(of: currentMedia!, on: reaction) == nil || scene.hasMultipleNext(for: currentMedia!)) {
//      return
//    }
    if reaction != Emotion.happy {
      return
    }
    if detectedReactions[currentMedia!] == nil {
      detectedReactions[currentMedia!] = []
    }
    if !detectedReactions[currentMedia!]!.contains(reaction) {
      App.log.debug("Detected \(reaction)")
      scene.increaseCounter(of: reaction)
      let event = InteractionEvent(
        timestamp: Date(), userId: App.authModule.current!.id, reaction: reaction,
        eventType: .reaction, sceneId: scene.id, mediaId: currentMedia!.id)
      InteractionApi.save(interaction: event)
        .on(value: { _ in
          App.log.debug("Interaction event successfully saved.")
        })
        .on(failed: { error in
          App.log.report("Could not save interaction event \(event) becuase of \(error)",
                         withError: error)
        })
        .start()
    }
    // Calculate next media
    if nextMedia == nil {
      nextMedia = scene.next(of: currentMedia!, on: reaction)
      if nextMedia != nil {
        App.log.debug("Next media: \(nextMedia!)")
      }
    }
    // Displays next media if the current one is finished.
    if delegate.mediaFinished() && nextMedia != nil {
      willDisplay(media: nextMedia!)
    }
    if lastReaction == nil || lastReaction! != reaction {
      reactionEmoji.value = reaction.emoji
      delegate.animateReactionImage()
    }
    updateReactionCounters(with: reaction)
    lastReaction = reaction
    detectedReactions[currentMedia!]!.insert(reaction)
  }
}

protocol SceneViewDelegate {

  /// Animates emotional reation image, so that the user see his reaction was captured.
  func animateReactionImage()

  /// Shows `alert` to the user, to inform him of errors and warnings.
  ///
  /// - Parameters:
  ///   - alert: message body of alert
  ///   - title: title at the top of the dislogue
  ///   - okAction: what the user clicks to terminate the dialogue
  func show(alert: String, title: String, okAction: String)

  /// Displays `media` to the user.
  ///
  /// - Parameter media: to display.
  func display(media: Media)

  /// - Returns: Whether the currently displayed media has finished.
  func mediaFinished() -> Bool

  /// Hides the displayed media if any.
  func hideMedia()
}

// MARK: MediaViewControllerDelegate
extension SceneViewModel: MediaViewControllerDelegate {
  func didDownloadMedia() {
    App.log.debug("didDownloadMedia")
    guard currentMedia != nil else {
      App.log.warning("Media downloaded but current media is nil")
      return
    }
    // Update media status
    mediaReady[currentMedia!] = true

    didDisplay()
  }

  func showLoader() {
    loadingImageHidden.value = false
  }

  func hideLoader() {
    loadingImageHidden.value = true
  }

  func didFinish() {
    if nextMedia != nil {
      willDisplay(media: nextMedia!)
    }
  }
}
