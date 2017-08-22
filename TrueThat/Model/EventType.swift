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
  case reactableView
  
  /// User reacted to a reactable.
  case reactableReaction
  
  public var description: String { return self.rawValue }
}

// MARK: Initialization
extension EventType {
  static func toEventType(_ name: String?) -> EventType? {
    if let camelCased = name?.camelCased() {
      switch camelCased {
      case String(describing: EventType.reactableView):
        return EventType.reactableView
      case String(describing: EventType.reactableReaction):
        return EventType.reactableReaction
      default:
        return nil
      }
    }
    return nil
  }
}
