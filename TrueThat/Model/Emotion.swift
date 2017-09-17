//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation

/// Emotions to describe emotional reaction to scenes.
enum Emotion: String, Hashable {
  case happy, fear, surprise, disgust

  public var description: String { return self.rawValue }

  var hashValue: Int {
    return self.rawValue.hashValue
  }
}

// MARK: Initialization
extension Emotion {
  static func toEmotion(_ name: String?) -> Emotion? {
    if let camelCased = name?.camelCased() {
      switch camelCased {
      case String(describing: Emotion.happy):
        return Emotion.happy
      case String(describing: Emotion.fear):
        return Emotion.fear
      case String(describing: Emotion.surprise):
        return Emotion.surprise
      case String(describing: Emotion.disgust):
        return Emotion.disgust
      default:
        return nil
      }
    }
    return nil
  }
}

// MARK: Emojis
extension Emotion {
  public var emoji: String {
    switch self {
    case .happy:
      return "😁"
    case .fear:
      return "😱"
    case .surprise:
      return "😮"
    case .disgust:
      return "😖"
    }
  }
}
