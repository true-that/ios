//
//  StudioViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class StudioViewModel {
  static let captureImageName = "capture_image.png"
  static let recordVideoImageName = "record.png"
  public let cameraSessionHidden = MutableProperty(false)
  public let reactablePreviewHidden = MutableProperty(true)
  public let captureButtonHidden = MutableProperty(false)
  public let cancelButtonHidden = MutableProperty(true)
  public let sendButtonHidden = MutableProperty(true)
  public let switchCameraButtonHidden = MutableProperty(false)
  public let captureButtonImageName = MutableProperty(StudioViewModel.captureImageName)
  var state = State.directing
  var delegate: StudioViewModelDelegate?
  var directed: Reactable?
  
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
    App.log.verbose("Studio state: \(State.directing)")
    state = State.directing
    directed = nil
    delegate?.displayPreview(of: nil)
    // Show camera preview and control buttons
    captureButtonHidden.value = false
    cameraSessionHidden.value = false
    switchCameraButtonHidden.value = false
    // Hide editting buttons, and hide directed reactable
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    reactablePreviewHidden.value = true
  }
  
  /// After a reactable is directed, it awaits for final approval from the user.
  func willApprove() {
    App.log.verbose("Studio state: \(State.approving)")
    guard directed != nil else {
      App.log.warning("Reached approval state with a nil directed reactable.")
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
    // Show editting buttons, and hide directed reactable
    cancelButtonHidden.value = false
    sendButtonHidden.value = false
    reactablePreviewHidden.value = false
  }
  
  /// After the user approved the reactable it is sent to our backend.
  func willSend() {
    App.log.verbose("Studio state: \(State.sent)")
    state = State.sent
    // Hide camera preview and control buttons
    captureButtonHidden.value = true
    cameraSessionHidden.value = true
    switchCameraButtonHidden.value = true
    // Hide editting buttons
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    // Show directed reactable
    reactablePreviewHidden.value = false
    
    if directed == nil {
      App.log.warning("Trying to send a non-existent reactable.")
      willApprove()
      return
    }
    _ = StudioApi.save(reactable: directed!)
      .on(value: { saved in
        if saved.id != nil {
          App.log.info("Reactable \(saved.id!) published successfully.")
          self.didPublish()
        } else {
          App.log.error("Reactable saved without ID.")
          self.willApprove()
        }
      })
      .on(failed: {error in
        App.log.error("Failed to save reactable: \(error)")
        self.willApprove()
      })
      .start()
  }
  
  /// After the reactable is successfully published, then leave the studio.
  func didPublish() {
    App.log.verbose("Studio state: \(State.published)")
    state = State.published
    delegate?.leaveStudio()
  }
  
  /// Invoked after a photo is captured and its data is available
  ///
  /// - Parameter imageData: of the fresh out of the oven image
  public func didCapture(imageData: Data) {
    directed = Pose(id: nil, userReaction: nil, director: App.authModule.current,
                    reactionCounters: nil, created: Date(), viewed: nil, imageData: imageData)
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
    directed = Short(id: nil, userReaction: nil, director: App.authModule.current,
                     reactionCounters: nil, created: Date(), viewed: nil, videoUrl: url)
    willApprove()
  }
  
  /// Studio various states
  ///
  /// - directing: when the user directs (creates and edits) a reactable.
  /// - approving: when a reactable is made and awaits for final approval from the user.
  /// - sent: when the user approved and sent the reactable to our backend.
  /// - published: when the reactable is successfully saved.
  enum State {
    case directing, approving, sent, published
  }
}

/// For interaction with relevant view controller.
protocol StudioViewModelDelegate {
  
  /// Leave studio, usually following reactable has been successfully saved.
  func leaveStudio()
  
  /// Displays a preview of the directed reactable.
  ///
  /// - Parameter reactable: that has just been directed.
  func displayPreview(of reactable: Reactable?)
}
