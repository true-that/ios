//
//  Pose.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Pose.java
class Pose: Reactable {
  /// Pose image part name when uploading a directed reactable
  static let poseImagePart = "pose_image"
  /// As stored in our backend.
  var imageUrl: String?
  
  /// Data of pose image that is to be saved on our backend (normally this field is populated only via studio pose).
  var imageData: Data?
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, imageUrl: String?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.imageUrl = imageUrl
  }
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, imageData: Data?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.imageData = imageData
  }
  
  required init(json: JSON) {
    super.init(json: json)
    imageUrl = json["imageUrl"].string
  }
  
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if imageUrl != nil {dictionary["imageUrl"] = imageUrl!}
    return dictionary
  }
  
  override func appendTo(multipartFormData: MultipartFormData) {
    super.appendTo(multipartFormData: multipartFormData)
    if imageData != nil {
      multipartFormData.append(imageData!, withName: Pose.poseImagePart, mimeType: "image/jpg")
    }
  }
}
