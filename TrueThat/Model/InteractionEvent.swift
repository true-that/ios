//
//  InteractionEvent.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

class InteractionEvent: BaseModel {
  // MARK: Properties
  
  /// Client UTC timestamp
  var timestamp: Date?
  
  /// ID of the {User} that triggered the event.
  var userId: Int64?
  
  /// For {reaction} events, leave null for irrelevant events.
  var reaction: Emotion?
  
  /// Interaction type
  var eventType: EventType?
  
  /// Of the {Reactable} that was interacted with.
  var reactableId: Int64?
  
  // MARK: Initialization
  init(timestamp: Date?, userId: Int64?, reaction: Emotion?, eventType: EventType?,
       reactableId: Int64?) {
    super.init()
    self.timestamp = timestamp
    self.userId = userId
    self.reaction = reaction
    self.eventType = eventType
    self.reactableId = reactableId
  }
  
  required init(json: JSON) {
    super.init(json: json)
    timestamp = DateHelper.utcDate(fromString: json["timestamp"].string)
    userId = json["userId"].int64
    reaction = Emotion.toEmotion(json["reaction"].string)
    eventType = EventType.toEventType(json["eventType"].string)
    reactableId = json["reactableId"].int64
  }
  
  // MARK: Overriden methods
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if timestamp != nil {dictionary["timestamp"] = DateHelper.utcDate(fromDate: timestamp)}
    if userId != nil {dictionary["userId"] = userId}
    if reaction != nil {dictionary["reaction"] = reaction?.rawValue}
    if eventType != nil {dictionary["eventType"] = eventType?.rawValue}
    if reactableId != nil {dictionary["reactableId"] = reactableId}
    return dictionary
  }
}
