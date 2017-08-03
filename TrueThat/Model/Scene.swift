//
//  Scene.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

class Scene: Reactable {
  
  /// As stored in our backend.
  var imageUrl: String?
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, imageUrl: String?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.imageUrl = imageUrl
  }
  
  required init(json: JSON) {
    super.init(json: json)
    imageUrl = json["imageUrl"].string
  }
}
