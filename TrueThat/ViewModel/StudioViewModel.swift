//
//  StudioViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Crashlytics
import ReactiveSwift
import Result

class StudioViewModel {
  public static let saveFailedTitle = "Our Bad!"
  public static let saveFailedOkText = "got it"
  public static let saveFailedAlert = "Your piece of art was not saved 🤕"
  static let captureImageName = "capture_image.png"
  static let recordVideoImageName = "record.png"
  public let cameraSessionHidden = MutableProperty(false)
  public let scenePreviewHidden = MutableProperty(true)
  public let captureButtonHidden = MutableProperty(false)
  public let cancelButtonHidden = MutableProperty(true)
  public let sendButtonHidden = MutableProperty(true)
  public let switchCameraButtonHidden = MutableProperty(false)
  public let loadingImageHidden = MutableProperty(true)
  public let previousMediaHidden = MutableProperty(true)
  public let captureButtonImageName = MutableProperty(StudioViewModel.captureImageName)
  var state = State.camera
  var delegate: StudioViewModelDelegate?
  var directed: Scene?
  var currentMedia: Media?
  var newMedia: Media?
  var chosenReaction: Emotion?

  // MARK: Lifecycle
  func didAppear() {
    switch state {
    case .camera:
      self.willDirect()
    case .edit:
      self.willEdit()
    case .sent:
      self.willSend()
    case .published:
      // Already published, and so resume directing
      self.willDirect()
    }
  }

  // MARK: Editing
  /// The user chose `reaction` as the follow up to `currentMedia`.
  ///
  /// - Parameter reaction: that should trigger the transition from `currentMedia`.
  func didChose(reaction: Emotion) {
    guard directed != nil, currentMedia != nil else {
      App.log.warning("Chose reaction before directed a scene.")
      return
    }
    if directed!.next(of: currentMedia!, on: reaction) != nil {
      currentMedia = directed!.next(of: currentMedia!, on: reaction)
      willEdit()
    } else {
      chosenReaction = reaction
      willDirect()
    }
  }

  /// Goes back to edit the previous media, from which the user can reach the current one.
  func displayingParentMedia() {
    // Should reach here only if the current media node has a parent.
    guard currentMedia != nil, directed?.parent(of: currentMedia!) != nil else {
      App.log.warning("Trying to display parent media when no such media exists")
      return
    }
    currentMedia = directed!.parent(of: currentMedia!)!
    willEdit()
  }

  /// User had dissapproved `currentMedia`.
  func didCancel() {
    App.log.debug("didCancel")
    guard directed != nil, currentMedia != nil else {
      App.log.warning("Canceled media before directing a scene.")
      return
    }
    currentMedia = directed!.remove(media: currentMedia!)
    if currentMedia != nil {
      willEdit()
    } else {
      directed = nil
      willDirect()
    }
  }

  // MARK: Studio states
  /// The state when directing had not been started yet (usually when the camera preview is live).
  func willDirect() {
    App.log.debug("Studio state: \(State.camera)")
    state = State.camera
    // Show camera preview and control buttons
    captureButtonHidden.value = false
    cameraSessionHidden.value = false
    switchCameraButtonHidden.value = false
    // Hide editting buttons, and hide directed scene
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    scenePreviewHidden.value = true
    // Hide loading image
    loadingImageHidden.value = true
    // Hides media preview
    delegate?.hideMedia()
  }

  /// After a scene is directed, it awaits for final approval from the user.
  func willEdit() {
    App.log.debug("Studio state: \(State.edit)")
    if newMedia == nil {
      guard directed != nil else {
        App.log.warning("Reached edit state with a nil directed scene and without a new media.")
        willDirect()
        return
      }
      guard currentMedia != nil else {
        App.log.warning("Reached edit state with a nil current media and without a new media.")
        if directed?.rootMedia != nil {
          currentMedia = directed?.rootMedia
          willEdit()
        } else {
          directed = nil
          willDirect()
        }
        return
      }
    } else {
      if directed == nil {
        directed = Scene(from: newMedia!)
        currentMedia = newMedia
      } else {
        guard currentMedia != nil, currentMedia?.id != nil else {
          App.log.warning("Reached edit state with an invalid current media and without a new media.")
          if directed?.rootMedia != nil {
            currentMedia = directed?.rootMedia
            willEdit()
          } else {
            directed = nil
            willDirect()
          }
          return
        }
        guard chosenReaction != nil else {
          App.log.warning("Trying to add a new media without a chosen reaction.")
          newMedia = nil
          willEdit()
          return
        }
        directed?.add(media: newMedia!, from: currentMedia!.id!, on: chosenReaction!)
        currentMedia = newMedia
        chosenReaction = nil
      }
      newMedia = nil
    }
    state = State.edit
    // Displays preview of current media
    delegate?.display(media: currentMedia!)
    scenePreviewHidden.value = false
    // Hide camera preview and control buttons
    captureButtonHidden.value = true
    cameraSessionHidden.value = true
    switchCameraButtonHidden.value = true
    // Show editting buttons, and hide directed scene
    cancelButtonHidden.value = false
    sendButtonHidden.value = false
    // Hide loading image
    loadingImageHidden.value = true
    // Expose previous media button if not editing root media.
    previousMediaHidden.value = currentMedia! == directed!.rootMedia!
  }

  /// After the user approved the scene it is sent to our backend.
  func willSend() {
    App.log.debug("Studio state: \(State.sent)")
    // Check that we have something to send
    if directed == nil {
      App.log.warning("Trying to send a non-existent scene.")
      willEdit()
      return
    }
    state = State.sent
    // Hide camera preview and control buttons
    captureButtonHidden.value = true
    cameraSessionHidden.value = true
    switchCameraButtonHidden.value = true
    // Hide editting buttons
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    // Show directed scene
    scenePreviewHidden.value = false
    // Show loading animation
    loadingImageHidden.value = false
    // Send save request
    _ = StudioApi.save(scene: directed!)
      .on(value: { saved in
        if saved.id != nil {
          App.log.info("Scene \(saved.id!) published successfully.")
          self.didPublish()
        } else {
          App.log.report("Scene saved without ID.",
                         withError: NSError(domain: Bundle.main.bundleIdentifier!,
                                            code: ErrorCode.badResponseData.rawValue,
                                            userInfo: nil))
          self.saveDidFail()
        }
      })
      .on(failed: { error in
        App.log.report(
          "Failed to save scene \(String(describing: self.directed)) because of \(error)",
          withError: error)
        self.saveDidFail()
      })
      .start()
    Crashlytics.sharedInstance().setObjectValue(
      directed?.toDictionary(),
      forKey: LoggingKey.directedScene.rawValue.snakeCased()!.uppercased())
  }

  /// After the scene is successfully published, then leave the studio.
  func didPublish() {
    App.log.debug("Studio state: \(State.published)")
    state = State.published
    // Hide loading image
    loadingImageHidden.value = true
    // Leave studio
    delegate?.leaveStudio()
  }

  /// Invoked after a network request to save `directed` had been failed.
  func saveDidFail() {
    self.delegate?.show(alert: StudioViewModel.saveFailedAlert,
                        title: StudioViewModel.saveFailedTitle,
                        okAction: StudioViewModel.saveFailedOkText)
    self.willEdit()
  }

  // MARK: Camera callbacks

  /// Invoked after a photo is captured and its data is available
  ///
  /// - Parameter imageData: of the fresh out of the oven image
  func didCapture(imageData: Data) {
    newMedia = Photo(data: imageData)
    willEdit()
  }

  /// Invoked when video recording has been started.
  func didStartRecordingVideo() {
    captureButtonImageName.value = StudioViewModel.recordVideoImageName
  }

  /// Invoked once video recording is finished.
  func didFinishRecordingVideo() {
    captureButtonImageName.value = StudioViewModel.captureImageName
  }

  /// Invoked once recorded video has been processed.
  func didFinishProcessVideo(url: URL) {
    newMedia = Video(localUrl: url)
    willEdit()
  }

  /// Studio various states
  ///
  /// - camera: when the user directs (creates and edits) a scene.
  /// - edit: when a scene is made and awaits for final approval from the user.
  /// - sent: when the user approved and sent the scene to our backend.
  /// - published: when the scene is successfully saved.
  enum State {
    case camera, edit, sent, published
  }
}

/// For interaction with relevant view controller.
protocol StudioViewModelDelegate {

  /// Leave studio, usually following scene has been successfully saved.
  func leaveStudio()

  /// Displays a preview of `currentMedia`
  ///
  /// - Parameter media: to display
  func display(media: Media)

  /// Hides any media preview.
  func hideMedia()

  /// Invoked once a HTTP request with the directed scene has been sent to the server.
  func didSend()

  func show(alert: String, title: String, okAction: String)
}
