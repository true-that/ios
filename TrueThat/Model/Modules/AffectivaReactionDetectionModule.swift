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
  fileprivate static let sumThreshold = 200 as CGFloat
  fileprivate static let iterationThreshold = 20 as CGFloat
  var detector: AFDXDetector?

  var emotionToLikelihood: [AffectivaEmotion: CGFloat] = [
    AffectivaEmotion.joy: 0,
    AffectivaEmotion.surprise: 0,
    AffectivaEmotion.anger: 0,
    AffectivaEmotion.sadness: 0,
    AffectivaEmotion.fear: 0,
    AffectivaEmotion.disgust: 0,
    ]
  fileprivate func resetLikelihood() {
    emotionToLikelihood = [
      AffectivaEmotion.joy: 0,
      AffectivaEmotion.surprise: 0,
      AffectivaEmotion.anger: 0,
      AffectivaEmotion.sadness: 0,
      AffectivaEmotion.fear: 0,
      AffectivaEmotion.disgust: 0,
    ]
  }

  override var delegate: ReactionDetectionDelegate? {
    didSet{
      resetLikelihood()
    }
  }

  override init() {
    super.init()
    detector = AFDXDetector(delegate: self, using: AFDX_CAMERA_FRONT, maximumFaces: 1)
    detector?.setDetectAllEmotions(true)
  }

  override func start() {
    resetLikelihood()
    super.start()
    if let error = detector?.start() {
      App.log.report("AFDXDetector: \(error)", withError: error as NSError)
    }
  }

  override func stop() {
    resetLikelihood()
    super.stop()
    if let error = detector?.stop() {
      App.log.report("AFDXDetector: \(error)", withError: error as NSError)
    }
  }
}

extension AffectivaReactionDetectionModule: AFDXDetectorDelegate {
  func detectorDidStartDetectingFace(face: AFDXFace) {
    print ("found face")
    resetLikelihood()
  }

  func detectorDidStopDetectingFace(face: AFDXFace) {
    print ("lost face")
    resetLikelihood()
  }

  func detector(_ detector: AFDXDetector, hasResults: NSMutableDictionary?, for forImage: UIImage,
                atTime: TimeInterval) {
    if hasResults != nil {
      for (_, face) in hasResults! {
        let affdexFace = face as! AFDXFace
        let currentLikelihood = [
          AffectivaEmotion.joy: affdexFace.emotions.joy,
          AffectivaEmotion.surprise: affdexFace.emotions.surprise,
          AffectivaEmotion.anger: affdexFace.emotions.anger,
          // Fear is harder to detect, and so it is amplified
          AffectivaEmotion.fear: affdexFace.emotions.fear * 3,
          // Negative emotions are too easy to detect, and so it is decreased
          AffectivaEmotion.sadness: affdexFace.emotions.sadness / 2,
          AffectivaEmotion.disgust: affdexFace.emotions.disgust / 2,
          ].filter{ $0.value > AffectivaReactionDetectionModule.iterationThreshold }
        currentLikelihood.forEach{ emotionToLikelihood[$0.key] = emotionToLikelihood[$0.key]! + $0.value }
        print ("\(currentLikelihood)")

        let significantEnough = emotionToLikelihood.filter { $1 > AffectivaReactionDetectionModule.sumThreshold }
        if significantEnough.isEmpty {
          return
        }
        let mostLikely = significantEnough.max(by: { $0.value > $1.value })
        if mostLikely != nil {
          delegate?.didDetect(reaction: mostLikely!.key.toEmotion()!, mostLikely: true)
        }
        for emotionLikelihoodEntry in significantEnough {
          if emotionLikelihoodEntry.key != mostLikely!.key {
            delegate?.didDetect(reaction: emotionLikelihoodEntry.key.toEmotion()!, mostLikely: false)
          }
        }
        if mostLikely != nil {
          resetLikelihood()
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
