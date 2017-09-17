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

  /// Of the {Scene} that was interacted with.
  var sceneId: Int64?

  /// ID of the media with which the user interacted.
  var mediaId: Int64?

  // MARK: Initialization
  init(timestamp: Date?, userId: Int64?, reaction: Emotion?, eventType: EventType?,
       sceneId: Int64?, mediaId: Int64?) {
    super.init(id: nil)
    self.timestamp = timestamp
    self.userId = userId
    self.reaction = reaction
    self.eventType = eventType
    self.sceneId = sceneId
    self.mediaId = mediaId
  }

  required init(json: JSON) {
    super.init(json: json)
    timestamp = DateHelper.utcDate(fromString: json["timestamp"].string)
    userId = json["userId"].int64
    reaction = Emotion.toEmotion(json["reaction"].string)
    eventType = EventType.toEventType(json["eventType"].string)
    sceneId = json["sceneId"].int64
    mediaId = json["mediaId"].int64
  }

  // MARK: Overriden methods
  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if timestamp != nil { dictionary["timestamp"] = DateHelper.utcDate(fromDate: timestamp) }
    if userId != nil { dictionary["userId"] = userId }
    if reaction != nil { dictionary["reaction"] = reaction?.rawValue.snakeCased()!.uppercased() }
    if eventType != nil { dictionary["eventType"] = eventType?.rawValue.snakeCased()!.uppercased() }
    if sceneId != nil { dictionary["sceneId"] = sceneId }
    if mediaId != nil { dictionary["mediaId"] = sceneId }
    return dictionary
  }
}
