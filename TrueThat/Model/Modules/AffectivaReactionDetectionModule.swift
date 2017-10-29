//
//  AffectivaReactionDetectionModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 08/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Affdex
import UIKit

class AffectivaReactionDetectionModule: ReactionDetectionModule {
  fileprivate static let detectionThreshold = 0.2 as CGFloat
  var detector: AFDXDetector?

  override init() {
    super.init()
    detector = AFDXDetector(delegate: self, using: AFDX_CAMERA_FRONT, maximumFaces: 1)
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

  func detector(_ detector: AFDXDetector, hasResults: NSMutableDictionary?, for forImage: UIImage,
                atTime: TimeInterval) {
    if hasResults != nil {
      for (_, face) in hasResults! {
        let affdexFace = face as! AFDXFace
        // Convert detected image to our enum
        let emotionToLikelihood = [
          AffectivaEmotion.joy: affdexFace.emotions.joy,
          AffectivaEmotion.surprise: affdexFace.emotions.surprise,
          AffectivaEmotion.anger: affdexFace.emotions.anger,
          AffectivaEmotion.sadness: affdexFace.emotions.sadness,
          // Fear is harder to detect, and so it is amplified
          AffectivaEmotion.fear: affdexFace.emotions.fear * 2,
          // Disgust is too easy to detect, and so it is decreased
          AffectivaEmotion.disgust: affdexFace.emotions.disgust / 2,
        ]
        let significantEnough = emotionToLikelihood.filter { $1 > AffectivaReactionDetectionModule.detectionThreshold }
        if significantEnough.isEmpty {
          return
        }
        let mostLikely = significantEnough.max(by: { $0.value > $1.value })
        if mostLikely != nil && delegate != nil {
          delegate?.didDetect(reaction: mostLikely!.key.toEmotion()!, mostLikely: true)
        }
        for emotionLikelihoodEntry in significantEnough {
          if emotionLikelihoodEntry.key != mostLikely!.key {
            delegate?.didDetect(reaction: emotionLikelihoodEntry.key.toEmotion()!, mostLikely: false)
          }
        }
      }
    }
  }
}

enum AffectivaEmotion: Int, Hashable {
  case joy, surprise, anger, sadness, fear, disgust

  var hashValue: Int {
    return self.rawValue.hashValue
  }

  func toEmotion() -> Emotion? {
    switch self {
    case .joy:
      return .happy
    case .surprise:
      return .omg
    case .fear:
      return .omg
    case .anger:
      return .disgust
    case .disgust:
      return .disgust
    case .sadness:
      return .disgust
    default:
      return nil
    }
  }
}
