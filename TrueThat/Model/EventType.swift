//
//  EventType.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation


/// `InteractionEvent` types.
enum EventType: String {
  
  /// User viewed a reactable.
  case REACTABLE_VIEW
  
  /// User reacted to a reactable.
  case REACTABLE_REACTION
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension EventType {
  static func toEventType(_ name: String?) -> EventType? {
    if let lowercased = name?.lowercased() {
      switch lowercased {
      case String(describing: EventType.REACTABLE_VIEW):
        return EventType.REACTABLE_VIEW
      case String(describing: EventType.REACTABLE_REACTION):
        return EventType.REACTABLE_REACTION
      default:
        return nil
      }
    }
    return nil
  }
}
