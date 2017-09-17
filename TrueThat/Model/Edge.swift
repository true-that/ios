//
//  Edge.swift
//  TrueThat
//
//  Created by Ohad Navon on 14/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Edge.java
/// Describes relations between media nodes and the flow in which user will interact with them.
/// `<0, 1, HAPPY>` means users that had a `HAPPY` reaction to the `0`-indexed media node will than view the `1`-indexed
/// node.
/// Note that we regard the `Media` node order in a `Scene`'s `mediaNodes` as its index.
///
/// See [backend].
class Edge: BaseModel {
  var sourceId: Int64?
  var targetId: Int64?
  var reaction: Emotion?
  
  // MARK: Initialization
  init(sourceId: Int64?, targetId: Int64?, reaction: Emotion?) {
    super.init(id: nil)
    self.sourceId = sourceId
    self.targetId = targetId
    self.reaction = reaction
  }
  
  required init(json: JSON) {
    super.init(json: json)
    sourceId = json["sourceId"].int64
    targetId = json["targetId"].int64
    reaction = Emotion.toEmotion(json["reaction"].string)
  }
  
  // MARK: Overriden methods
  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if sourceId != nil { dictionary["sourceId"] = sourceId }
    if targetId != nil { dictionary["targetId"] = targetId }
    if reaction != nil { dictionary["reaction"] = reaction?.rawValue.snakeCased()!.uppercased() }
    return dictionary
  }
}
