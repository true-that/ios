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
  public let captureButtonImageName = MutableProperty(StudioViewModel.captureImageName)
  var state = State.directing
  var delegate: StudioViewModelDelegate?
  var directed: Scene?

  public func didAppear() {
    switch state {
    case .directing:
      self.willDirect()
    case .approving:
      self.willApprove()
    case .sent:
      self.willSend()
    case .published:
      // Already published, and so resume directing
      self.willDirect()
    }
  }

  /// The state when directing had not been started yet (usually when the camera preview is live).
  func willDirect() {
    App.log.debug("Studio state: \(State.directing)")
    state = State.directing
    directed = nil
    delegate?.displayPreview(of: nil)
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
  }

  /// After a scene is directed, it awaits for final approval from the user.
  func willApprove() {
    App.log.debug("Studio state: \(State.approving)")
    guard directed != nil else {
      App.log.warning("Reached approval state with a nil directed scene.")
      willDirect()
      return
    }
    state = State.approving
    // Displays preview
    delegate?.displayPreview(of: directed!)
    // Hide camera preview and control buttons
    captureButtonHidden.value = true
    cameraSessionHidden.value = true
    switchCameraButtonHidden.value = true
    // Show editting buttons, and hide directed scene
    cancelButtonHidden.value = false
    sendButtonHidden.value = false
    scenePreviewHidden.value = false
    // Hide loading image
    loadingImageHidden.value = true
  }

  /// After the user approved the scene it is sent to our backend.
  func willSend() {
    App.log.debug("Studio state: \(State.sent)")
    // Check that we have something to send
    if directed == nil {
      App.log.warning("Trying to send a non-existent scene.")
      willApprove()
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
                        withTitle: StudioViewModel.saveFailedTitle,
                        okAction: StudioViewModel.saveFailedOkText)
    self.willApprove()
  }

  /// Invoked after a photo is captured and its data is available
  ///
  /// - Parameter imageData: of the fresh out of the oven image
  public func didCapture(imageData: Data) {
    directed = Scene(of: Photo(data: imageData))
    willApprove()
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
    directed = Scene(of: Video(localUrl: url))
    willApprove()
  }

  /// Studio various states
  ///
  /// - directing: when the user directs (creates and edits) a scene.
  /// - approving: when a scene is made and awaits for final approval from the user.
  /// - sent: when the user approved and sent the scene to our backend.
  /// - published: when the scene is successfully saved.
  enum State {
    case directing, approving, sent, published
  }
}

/// For interaction with relevant view controller.
protocol StudioViewModelDelegate {

  /// Leave studio, usually following scene has been successfully saved.
  func leaveStudio()

  /// Displays a preview of the directed scene.
  ///
  /// - Parameter scene: that has just been directed.
  func displayPreview(of scene: Scene?)

  /// Invoked once a HTTP request with the directed scene has been sent to the server.
  func didSend()

  /// Shows `alert` to the user, to inform him of errors and warnings.
  ///
  /// - Parameters:
  ///   - alert: message body of alert
  ///   - withTitle: title at the top of the dislogue
  ///   - okAction: what the user clicks to terminate the dialogue
  func show(alert: String, withTitle: String, okAction: String)
}
