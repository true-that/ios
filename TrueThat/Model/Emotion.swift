//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation

/// Emotions to describe emotional reaction to reactables.
enum Emotion: String {
  case HAPPY, SAD
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension Emotion {
  static func toEmotion(_ name: String?) -> Emotion? {
    if let lowercased = name?.lowercased() {
      switch lowercased {
      case String(describing: Emotion.HAPPY):
        return Emotion.HAPPY
      case String(describing: Emotion.SAD):
        return Emotion.SAD
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
    case .HAPPY:
      return "😁"
    case .SAD:
      return "☹️"
    }
  }
}
