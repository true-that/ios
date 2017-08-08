//
//  FakeReactionDetectionModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FakeReactionDetectionModule: ReactionDetectionModule {
  
  /// Fakes a detection of reaction.
  ///
  /// - Parameter reaction: that was detected.
  public func detect(_ reaction: Emotion) {
    App.log.verbose("Detected \(reaction)")
    delegate?.didDetect(reaction: reaction)
  }
}
