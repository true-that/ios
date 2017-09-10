//
//  AffectivaReactionDetectionModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 08/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Affdex

class AffectivaReactionDetectionModule: ReactionDetectionModule {
  fileprivate static let emotionThreshold = 0.2 as CGFloat
  var detector: AFDXDetector?

  override init() {
    super.init()
    detector = AFDXDetector(delegate:self, using:AFDX_CAMERA_FRONT, maximumFaces: 1)
    detector?.setDetectAllEmotions(true)
  }

  override func start() {
    super.start()
    if let error = detector?.start() {
      App.log.report("AFDXDetector: \(error)", withError: error as NSError)
    }
  }

  override func stop() {
    super.stop()
    if let error = detector?.stop() {
      App.log.report("AFDXDetector: \(error)", withError: error as NSError)
    }
  }
}

extension AffectivaReactionDetectionModule: AFDXDetectorDelegate {
  func detectorDidStartDetectingFace(face: AFDXFace) {
  }
  func detectorDidStopDetectingFace(face: AFDXFace) {
  }

  func detector(_ detector: AFDXDetector, hasResults: NSMutableDictionary?, for forImage: UIImage, atTime: TimeInterval) {
    // handle processed and unprocessed images here
    if hasResults != nil {
      // enumrate the dictionary of faces
      for (_, face) in hasResults! {
        let affdexFace = face as! AFDXFace
        // Convert detected image to our enum
        var detected: Emotion?
        if affdexFace.emotions.joy > AffectivaReactionDetectionModule.emotionThreshold {
          detected = .happy
        } else if affdexFace.emotions.sadness > AffectivaReactionDetectionModule.emotionThreshold {
          detected = .sad
        }
        if detected != nil && delegate != nil {
          App.log.verbose("Detected \(detected!)")
          delegate?.didDetect(reaction: detected!)
        }
      }
    } else {
      // handle unprocessed image in this block of code
    }
  }
}
