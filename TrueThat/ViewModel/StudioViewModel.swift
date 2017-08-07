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
      self.directing()
    case .approving:
      self.approving()
    case .sent:
      self.didSend()
    case .published:
      // Already published, and so resume directing
      self.directing()
    }
  }
  
  public func didCapture(imageData: Data) {
    directed = Scene(id: nil, userReaction: nil, director: App.authModule.current!,
                     reactionCounters: nil, created: Date(), viewed: nil, imageData: imageData)
    approving()
  }
  
  func directing() {
    App.log.verbose("Studio state: \(State.directing)")
    state = State.directing
    directed = nil
    captureButtonHidden.value = false
    switchCameraButtonHidden.value = false
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    delegate?.restorePreview()
  }
  
  func approving() {
    App.log.verbose("Studio state: \(State.approving)")
    state = State.approving
    captureButtonHidden.value = true
    switchCameraButtonHidden.value = true
    cancelButtonHidden.value = false
    sendButtonHidden.value = false
  }
  
  func didSend() {
    App.log.verbose("Studio state: \(State.sent)")
    state = State.sent
    captureButtonHidden.value = true
    switchCameraButtonHidden.value = true
    cancelButtonHidden.value = true
    sendButtonHidden.value = true
    
    if directed == nil {
      App.log.warning("Trying to send a non-existent reactable.")
      directing()
      return
    }
    _ = StudioApi.save(reactable: directed!)
      .on(value: { saved in
        if saved.id != nil {
          App.log.info("Reactable \(saved.id!) published successfully.")
          self.didPublish()
        } else {
          App.log.error("Reactable saved without ID.")
          self.approving()
        }
      })
      .on(failed: {error in
        App.log.error("Failed to save reactable: \(error)")
        self.approving()
      })
      .start()
  }
  
  func didPublish() {
    App.log.verbose("Studio state: \(State.published)")
    state = State.published
    delegate?.leaveStudio()
  }
  
  enum State {
    case directing, approving, sent, published
  }
}

protocol StudioViewModelDelegate {
  func restorePreview()
  
  func leaveStudio()
}
