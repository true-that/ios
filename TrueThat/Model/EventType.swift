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
  case view
  
  /// User reacted to a reactable.
  case reaction
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension EventType {
  static func toEventType(_ name: String?) -> EventType? {
    if let lowercased = name?.lowercased() {
      switch lowercased {
      case String(describing: EventType.view):
        return EventType.view
      case String(describing: EventType.reaction):
        return EventType.reaction
      default:
        return nil
      }
    }
    return nil
  }
}
