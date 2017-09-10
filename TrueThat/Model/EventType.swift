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
  
  /// User viewed a scene.
  case view
  
  /// User reacted to a scene.
  case reaction
  
  /// Report a scene as inappropriate.
  case report
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension EventType {
  static func toEventType(_ name: String?) -> EventType? {
    if let camelCased = name?.camelCased() {
      switch camelCased {
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
