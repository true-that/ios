//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Scene.java
/// Scenes add spice to our users life, they are the an abstract pieces of media consumed by our
/// users. See [backend]
class Scene: BaseModel {
  /// As stored in our backend.
  var id: Int64?
  /// The current user reaction to it.
  var userReaction: Emotion?
  /// Creator of the scene.
  var director: User?
  /// Reaction counters.
  var reactionCounters: [Emotion: Int64]?
  /// Date of creation.
  var created: Date?
  /// Whether the scene was already viewed by the current user.
  var viewed: Bool?
  /// Media of scene, such as a photo.
  var media: Media?

  // MARK: Initialization
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, media: Media?) {
    super.init()
    self.id = id
    self.userReaction = userReaction
    self.director = director
    self.created = created
    self.viewed = viewed
    self.reactionCounters = reactionCounters
    self.media = media
  }

  required init(json: JSON) {
    super.init(json: json)
    id = json["id"].int64
    userReaction = Emotion.toEmotion(json["userReaction"].string)
    director = User(json: json["director"])
    created = DateHelper.utcDate(fromString: json["created"].string)
    viewed = json["viewed"].bool
    reactionCounters = json["reactionCounters"].dictionary?.mapPairs { stringEmotion, counter in
      (Emotion.toEmotion(stringEmotion)!, counter.int64Value)
    }
    if json["media"] != JSON.null {
      media = Media.instantiate(with: json["media"])
    }
  }

  // MARK: overriden methods
  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if id != nil {
      dictionary["id"] = id!
    }
    if userReaction != nil {
      dictionary["userReaction"] = userReaction!.rawValue.snakeCased()!.uppercased()
    }
    if director != nil {
      dictionary["director"] = director!.toDictionary()
    }
    if reactionCounters != nil {
      dictionary["reactionCounters"] = reactionCounters!
        .mapPairs { emotion, counter in (emotion.rawValue.snakeCased()!.uppercased(), counter) }
    }
    if created != nil {
      dictionary["created"] = DateHelper.utcDate(fromDate: created!)
    }
    if viewed != nil {
      dictionary["viewed"] = viewed!
    }
    if media != nil {
      dictionary["media"] = media?.toDictionary()
    }

    return dictionary
  }

  // MARK: Interaction

  /// - Parameter user: for which to inquire.
  /// - Returns: Whether `user` can react to this scene.
  func canReact(user: User) -> Bool {
    return userReaction == nil && (director == nil || user != director)
  }

  /// Updates reaction counters of this scene with `reaction`
  ///
  /// - Parameter reaction: to update with
  func updateReactionCounters(with reaction: Emotion) {
    if reactionCounters == nil {
      reactionCounters = [reaction: 1]
    } else if reactionCounters![reaction] == nil {
      reactionCounters![reaction] = 1
    } else {
      reactionCounters![reaction] = 1 + reactionCounters![reaction]!
    }
  }

  // MARK: Network

  /// Appends scene data to a multipart request
  ///
  /// - Parameter multipartFormData: to append to
  func appendTo(multipartFormData: MultipartFormData) {
    let sceneData = try? JSON(toDictionary()).rawData()
    if sceneData != nil {
      multipartFormData.append(sceneData!, withName: StudioApi.scenePart)
    }
    if media != nil {
      media!.appendTo(multipartFormData: multipartFormData)
    }
  }
}
