//
//  ReactionDetectionModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Manages emotional reaction detection.
class ReactionDetectionModule {
  
  /// Notifies this delegate for detected reactions.
  public var delegate: ReactionDetectionDelegate?
  
  /// Starts detecting facial reactions
  func start() {
    App.log.verbose("starting reaction detection...")
  }
  
  
  /// Stops detecting reactions, and freeing used resources.
  func stop() {
    App.log.verbose("stopping reaction detection...")
  }
}

protocol ReactionDetectionDelegate {
  
  /// Callback for detected reactions handling.
  ///
  /// - Parameter reaction: that was detected.
  func didDetect(reaction: Emotion)
}
