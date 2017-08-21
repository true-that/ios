//
//  Scene.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Scene.java
class Scene: Reactable {
  /// Scene image part name when uploading a directed reactable
  static let sceneImagePart = "scene_image"
  /// As stored in our backend.
  var imageSignedUrl: String?
  
  /// Data of scene image that is to be saved on our backend (normally this field is populated only via studio scene).
  var imageData: Data?
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, imageSignedUrl: String?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.imageSignedUrl = imageSignedUrl
  }
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, imageData: Data?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.imageData = imageData
  }
  
  required init(json: JSON) {
    super.init(json: json)
    imageSignedUrl = json["imageSignedUrl"].string
  }
  
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if imageSignedUrl != nil {dictionary["imageSignedUrl"] = imageSignedUrl!}
    return dictionary
  }
  
  override func appendTo(multipartFormData: MultipartFormData) {
    super.appendTo(multipartFormData: multipartFormData)
    if imageData != nil {
      multipartFormData.append(imageData!, withName: Scene.sceneImagePart, mimeType: "image/jpg")
    }
  }
}
