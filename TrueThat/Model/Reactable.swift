//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import SwiftyJSON


/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Reactable.java
/// Reactables add spice to our users life, they are the an abstract pieces of media consumed by our
/// users. See [backend]
class Reactable: BaseModel {
  /// As stored in our backend.
  var id: Int64?
  /// The current user reaction to it.
  var userReaction: Emotion?
  /// Creator of the reactable.
  var director: User?
  /// Reaction counters.
  var reactionCounters: [Emotion: Int64]?
  /// Date of creation.
  var created: Date?
  /// Whether the reactable was already viewed by the current user.
  var viewed: Bool?

  // MARK: Initialization
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?) {
    super.init()
    self.id = id
    self.userReaction = userReaction
    self.director = director
    self.created = created
    self.viewed = viewed
    self.reactionCounters = reactionCounters
  }
  
  required init(json: JSON) {
    super.init(json: json)
    id = json["id"].int64
    userReaction = Emotion.toEmotion(json["userReaction"].string)
    director = User(json: json["director"])
    created = DateHelper.utcDate(fromString: json["created"].string)
    viewed = json["viewed"].bool
    reactionCounters = json["reactionCounters"].dictionary?.mapPairs{ (stringEmotion, counter) in
      (Emotion.toEmotion(stringEmotion)!, counter.int64Value)
    }
  }
  
  static func instantiate(with json: JSON) -> Reactable? {
    switch json["type"].stringValue {
    case String(describing: Reactable.self):
      return Reactable(json: json)
    case String(describing: Scene.self):
      return Scene(json: json)
    default:
      return nil
    }
  }
  
  // MARK: overriden methods
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if (id != nil) {
      dictionary["id"] = id!
    }
    if (userReaction != nil) {
      dictionary["userReaction"] = userReaction!.rawValue
    }
    if (director != nil) {
      dictionary["director"] = director!.toDictionary()
    }
    if (reactionCounters != nil) {
      dictionary["reactionCounters"] = reactionCounters!.mapPairs{(emotion, counter) in (emotion.rawValue, counter)}
    }
    if (created != nil) {
      dictionary["created"] = DateHelper.utcDate(fromDate: created!)
    }
    if (viewed != nil) {
      dictionary["viewed"] = viewed!
    }
    
    return dictionary
  }
}
