//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation

/// Emotions to describe emotional reaction to reactables.
enum Emotion: String {
  case happy, sad
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension Emotion {
  static func toEmotion(_ name: String?) -> Emotion? {
    if let camelCased = name?.camelCased() {
      switch camelCased {
      case String(describing: Emotion.happy):
        return Emotion.happy
      case String(describing: Emotion.sad):
        return Emotion.sad
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
    case .sad:
      return "☹️"
    }
  }
}
