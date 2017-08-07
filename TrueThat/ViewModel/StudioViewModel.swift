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
  public let captureButtonHidden = MutableProperty(false)
  public let cancelButtonHidden = MutableProperty(true)
  public let sendButtonHidden = MutableProperty(true)
  public let switchCameraButtonHidden = MutableProperty(false)
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
      self.didSend()
    case .published:
      // Already published, and so resume directing
      self.willDirect()
    }
  }
  
  /// Invoked after a photo is captured and its data is available
  ///
  /// - Parameter imageData: of the fresh out of the oven image
  public func didCapture(imageData: Data) {
    directed = Scene(id: nil, userReaction: nil, director: App.authModule.current!,
                     reactionCounters: nil, created: Date(), viewed: nil, imageData: imageData)
    willApprove()
  }
  
  /// The state when directing had not been started yet (usually when the camera preview is live).
  func willDirect() {
    App.log.verbose("Studio state: \(State.directing)")
    state = State.directing
    directed = nil
    captureButtonHidden.value = false
    switchCameraButtonHidden.value = false
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    delegate?.restorePreview()
  }
  
  /// After a reactable is directed, it awaits for final approval from the user.
  func willApprove() {
    App.log.verbose("Studio state: \(State.approving)")
    state = State.approving
    captureButtonHidden.value = true
    switchCameraButtonHidden.value = true
    cancelButtonHidden.value = false
    sendButtonHidden.value = false
  }
  
  /// After the user approved the reactable it is sent to our backend.
  func didSend() {
    App.log.verbose("Studio state: \(State.sent)")
    state = State.sent
    captureButtonHidden.value = true
    switchCameraButtonHidden.value = true
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    
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
  
  /// Restore camera preview
  func restorePreview()
  
  /// Leave studio, usually following reactable has been successfully saved.
  func leaveStudio()
}
