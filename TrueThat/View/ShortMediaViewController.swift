//
//  ShortMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ShortMediaViewController: ReactableMediaViewController {
  // MARK: Properties
  var short: Short?
  var player: AVPlayer?
  var playerController : AVPlayerViewController?
  
  // MARK: Initialization
  static func instantiate(_ short: Short) -> ShortMediaViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ShortMediaScene")
      as! ShortMediaViewController
    viewController.short = short
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    playerController = AVPlayerViewController()
    playerController?.view.accessibilityLabel = "short video"
    if short?.videoUrl != nil {
      player = AVPlayer(url: short!.videoUrl!)
    } else if short?.videoLocalUrl != nil {
      player = AVPlayer(url: short!.videoLocalUrl!)
    }
    
    guard player != nil && playerController != nil else {
      return
    }
    // Hides playback controls
    playerController!.showsPlaybackControls = false
    playerController!.player = player!
    
    // Adds the player to the view
    self.addChildViewController(playerController!)
    self.view.addSubview(playerController!.view)
    playerController!.view.frame = view.frame
    
    // Enables looping
    NotificationCenter.default.addObserver(
      self, selector: #selector(playerItemDidReachEnd),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    
    // Add player control via touch
    let gesture = UILongPressGestureRecognizer(
      target: self, action: #selector(controlVideo(_:)))
    gesture.minimumPressDuration = 0
    gesture.allowableMovement = 1000
    playerController!.view.addGestureRecognizer(gesture)
    
    // Show loader when buffering
    player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
    player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if player != nil {
      App.log.verbose("playing video")
      player?.play()
    } else {
      App.log.verbose("not playing video, because player is not ready.")
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    player?.pause()
  }
  
  // MARK: AVPlayer
  /// Pauses and plays video as per user touch events.
  @objc fileprivate func controlVideo(_ recognizer: UIGestureRecognizer) {
    if player != nil {
      if recognizer.state == .began {
        App.log.verbose("pausing video")
        player!.pause()
      } else if recognizer.state == .ended {
        App.log.verbose("resuming video")
        player!.play()
      }
    }
  }
  
  /// Loops the player to the beginning of the video, normally invoked once the video is completed.
  ///
  /// - Parameter notification: to associate with the observer.
  @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
    if player != nil {
      player!.seek(to: kCMTimeZero)
      player!.play()
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard object is AVPlayerItem && keyPath != nil else {
      return
    }
    switch keyPath! {
    case "playbackBufferEmpty":
      App.log.verbose("buffering video")
      delegate?.showLoader()
      break
    case "playbackLikelyToKeepUp":
      App.log.verbose("beffering video completed")
      self.delegate?.didDownloadMedia()
      delegate?.hideLoader()
      break
    case "playbackBufferFull":
      App.log.verbose("beffering video completed, but might recur")
      delegate?.hideLoader()
      break
    default:
      break
    }
  }
}
