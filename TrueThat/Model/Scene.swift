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
  /// Media items of this scene, such as a photo.
  var mediaNodes: [Media]?
  /// The flow of the user interaction with this scene. Each node represents a media item such as video or a photo and
  /// each edge describe which reaction leads from one media item to the next.
  var edges: [Edge]?
  
  /// The starting point of this scene. All users will begin viewing this media before all others.
  var rootMedia: Media? {
    if mediaNodes != nil && !mediaNodes!.isEmpty {
      return mediaNodes![0]
    }
    return nil
  }

  // MARK: Initialization
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, mediaNodes: [Media]?, edges: [Edge]?) {
    super.init()
    self.id = id
    self.userReaction = userReaction
    self.director = director
    self.created = created
    self.viewed = viewed
    self.reactionCounters = reactionCounters
    self.mediaNodes = mediaNodes
    self.edges = edges
  }
  
  convenience init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, media: Media?) {
    var mediaNodes: [Media]? = nil
    if media != nil {
      mediaNodes = [media!]
    }
    self.init(id: id, userReaction: userReaction, director: director, reactionCounters: reactionCounters,
              created: created, viewed: viewed, mediaNodes: mediaNodes, edges: nil)
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
    if json["mediaNodes"].array != nil {
      mediaNodes = json["mediaNodes"].arrayValue.map{ Media.instantiate(with: $0)! }
    }
    if json["edges"].array != nil {
      edges = json["edges"].arrayValue.map{ Edge(json: $0) }
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
    if mediaNodes != nil {
      dictionary["mediaNodes"] = mediaNodes!.map { $0.toDictionary() }
    }
    if edges != nil {
      dictionary["edges"] = edges!.map { $0.toDictionary() }
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
  
  func partName(of: Int) -> String {
    return StudioApi.mediaPartPrefix + "\(of)"
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
    if mediaNodes != nil {
      for i in 0 ..< mediaNodes!.count  {
        mediaNodes![i].appendTo(multipartFormData: multipartFormData, withName: partName(of: i))
      }
    }
  }
}
