//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation

/// Emotions to describe emotional reaction to scenes.
enum Emotion: String, Hashable {
  case happy, fear /* deprecated */, surprised /* deprecated */, omg, disgust

  public var description: String { return self.rawValue }

  var hashValue: Int {
    return self.rawValue.hashValue
  }

  static let values = [Emotion.happy, Emotion.omg, Emotion.disgust]
}

// MARK: Initialization
extension Emotion {
  static func toEmotion(_ name: String?) -> Emotion? {
    if let camelCased = name?.camelCased() {
      switch camelCased {
      case String(describing: Emotion.happy):
        return Emotion.happy
      case String(describing: Emotion.omg):
        return Emotion.omg
      case String(describing: Emotion.disgust):
        return Emotion.disgust
      case String(describing: Emotion.fear):
        return Emotion.fear
      case String(describing: Emotion.surprised):
        return Emotion.surprised
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
    case .disgust:
      return "😖"
    case .omg:
      return "😱"
    default:
      return "😱"
    }
  }
}
