//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import ReactiveSwift
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Scene.java
/// Scenes add spice to our users life, they are the an abstract pieces of media consumed by our
/// users. See [backend]
class Scene: BaseModel {

  /// Creator of the scene.
  var director: User?
  /// Reaction counters.
  var reactionCounters: [Emotion: Int64]?
  /// Date of creation.
  var created: Date?
  /// Media items of this scene, such as a photo.
  var mediaNodes: [Media]?
  /// The flow of the user interaction with this scene. Each node represents a media item such as video or a photo and
  /// each edge describe which reaction leads from one media item to the next.
  var edges: [Edge]?
  /// Allocates the next media ID.
  var nextMediaId: Int64 = 0

  /// Whether the media items are ready tobe sent over the network
  var isPrepared: Bool {
    if mediaNodes == nil {
      return true
    }
    for media in mediaNodes! {
      if !media.isPrepared {
        return false
      }
    }
    return true
  }

  /// Producer that is used to save this scene on our backend.
  var savingProducer: SignalProducer<Scene, NSError>?

  /// The flow of the user interaction with this scene. Each node represents a media item such as video or a photo and
  /// each edge describe which reaction leads from one media item to the next.
  var flowTree: FlowTree! {
    if treeInstance == nil {
      treeInstance = FlowTree(delegate: self)
      if mediaNodes != nil {
        for media in mediaNodes! {
          treeInstance.add(media: media)
        }
      }
      if edges != nil {
        for edge in edges! {
          treeInstance.add(edge: edge)
        }
      }
      if !treeInstance.isTree {
        App.log.report("Invalid media tree", withError: NSError(domain: Bundle.main.bundleIdentifier!,
                                                                code: ErrorCode.mediaTree.rawValue,
                                                                userInfo: [
                                                                  "mediaNodes": mediaNodes ?? [],
                                                                  "edges": edges ?? [],
        ]))
        return nil
      }
    }
    return treeInstance
  }

  var treeInstance: FlowTree!

  /// The starting point of this scene. All users will begin viewing this media before all others.
  var rootMedia: Media? {
    return flowTree.root
  }

  // MARK: Initialization
  init(id: Int64?, director: User?, reactionCounters: [Emotion: Int64]?, created: Date?, mediaNodes: [Media]?,
       edges: [Edge]?) {
    super.init(id: id)
    self.director = director
    self.created = created
    self.reactionCounters = reactionCounters
    self.mediaNodes = mediaNodes
    if mediaNodes != nil {
      for media in mediaNodes! {
        if media.id == nil {
          media.id = nextMediaId
          nextMediaId += 1
        }
      }
    }
    self.edges = edges
  }

  convenience init(from media: Media) {
    self.init(id: nil, director: App.authModule.current, reactionCounters: nil, created: Date(),
              mediaNodes: [media], edges: nil)
    media.delegate = self
  }

  required init(json: JSON) {
    super.init(json: json)
    director = User(json: json["director"])
    if director == nil {
      App.log.warning("Missing director.")
    }
    created = DateHelper.utcDate(fromString: json["created"].string)
    if created == nil {
      App.log.warning("Missing created.")
    }
    reactionCounters = json["reactionCounters"].dictionary?.mapPairs { stringEmotion, counter in
      (Emotion.toEmotion(stringEmotion)!, counter.int64Value)
    }
    if json["mediaNodes"].array != nil {
      mediaNodes = json["mediaNodes"].arrayValue.map { Media.instantiate(with: $0)! }
    }
    if mediaNodes == nil {
      App.log.warning("Missing mediaNodes.")
    } else if mediaNodes!.isEmpty {
      App.log.warning("No media nodes.")
    }
    if json["edges"].array != nil {
      edges = json["edges"].arrayValue.map { Edge(json: $0) }
    }
  }

  // MARK: overriden methods
  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
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
    if mediaNodes != nil {
      dictionary["mediaNodes"] = mediaNodes!.map { $0.toDictionary() }
    }
    if edges != nil {
      dictionary["edges"] = edges!.map { $0.toDictionary() }
    }

    return dictionary
  }

  // MARK: Methods

  /// Increase reaction counter of `reaction`.
  ///
  /// - Parameter reaction: to update with
  func increaseCounter(of reaction: Emotion) {
    if reactionCounters == nil {
      reactionCounters = [reaction: 1]
    } else if reactionCounters![reaction] == nil {
      reactionCounters![reaction] = 1
    } else {
      reactionCounters![reaction] = 1 + reactionCounters![reaction]!
    }
  }

  // Mark: Media
  /// Adds `media` to the flow tree.
  ///
  /// - Parameters:
  ///   - media: to add
  ///   - parentId: desired parent media ID.
  ///   - reaction: that should trigger transition from parent to child media.
  func add(media: Media, from parentId: Int64, on reaction: Emotion) {
    media.delegate = self
    if media.id == nil {
      media.id = nextMediaId
      nextMediaId += 1
    }
    mediaNodes?.append(media)
    let edge = Edge(sourceId: parentId, targetId: media.id!, reaction: reaction)
    if edges == nil {
      edges = []
    }
    edges!.append(edge)
    flowTree.add(media: media)
    flowTree.add(edge: edge)
  }

  /// - Parameters:
  ///   - media: what the user is currently viewing.
  ///   - reaction: how he reacted to it.
  /// - Returns: the media, if any, that he should now view.
  func next(of media: Media, on reaction: Emotion) -> Media? {
    return flowTree.child(of: media.id!, emotion: reaction)
  }

  /// - Parameter media: current media
  /// - Returns: whether `for` has multiple next media options.
  func hasMultipleNext(for media: Media) -> Bool {
    if flowTree.nodes[media.id!] == nil {
      return false
    }
    return flowTree.nodes[media.id!]!.children.count > 1
  }

  /// - Parameter media: what the user is currently viewing
  /// - Returns: the media, if any, that led to the current one.
  func parent(of media: Media) -> Media? {
    return flowTree.parent(of: media.id!)
  }

  /// Removes `media` from this scene.
  ///
  /// - Parameter media: to remove
  /// - Returns: the parent media.
  func remove(media: Media) -> Media? {
    return flowTree.remove(at: media.id!)
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
      for media in mediaNodes! {
        media.appendTo(multipartFormData: multipartFormData)
      }
    }
  }

  /// Save this scene on our backend.
  func save() -> SignalProducer<Scene, NSError> {
    savingProducer = SignalProducer { observer, _ in
      _ = StudioApi.save(scene: self)
        .on(value: { saved in
          if saved.id != nil {
            App.log.info("Scene \(saved.id!) saved successfully.")
            observer.send(value: self)
            observer.sendCompleted()
          } else {
            let error = NSError(domain: Bundle.main.bundleIdentifier!,
                                code: ErrorCode.badResponseData.rawValue,
                                userInfo: nil)
            App.log.report("Scene saved without ID.", withError: error)
            observer.send(error: error)
          }
        })
        .on(failed: { error in
          App.log.report("Failed to save scene \(self) because of \(error)", withError: error)
          observer.send(error: error)
        })
        .start()
    }
    if isPrepared {
      savingProducer?.start()
    }
    return savingProducer!
  }
}

// MARK: FlowTreeDelegate
extension Scene: FlowTreeDelegate {
  func delete(media: Media) {
    let toRemoveIndex = mediaNodes?.index(of: media)
    guard toRemoveIndex != nil else {
      App.log.error("Media node \(media) is not a part of this scene \(self)")
      return
    }
    mediaNodes?.remove(at: toRemoveIndex!)
  }

  func delete(edge: Edge) {
    let toRemove = edges?.index(of: edge)
    if toRemove != nil {
      edges!.remove(at: toRemove!)
    }

  }
}

// MARK: MediaPreparedDelegate
extension Scene: MediaPreparedDelegate {
  func didPrepare() {
    if savingProducer != nil && isPrepared {
      savingProducer?.start()
    }
  }
}
