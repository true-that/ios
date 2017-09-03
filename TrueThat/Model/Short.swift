//
//  Short.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Short.java
class Short: Reactable {
  /// Short video part name when uploading a directed reactable
  static let shortVideoPart = "short_video"
  /// As stored in our backend
  var videoUrl: URL?
  
  /// As stored in the device file system
  var videoLocalUrl: URL?
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, videoUrl: URL?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.videoUrl = videoUrl
  }
  
  init(id: Int64?, userReaction: Emotion?, director: User?, reactionCounters: [Emotion: Int64]?,
       created: Date?, viewed: Bool?, videoLocalUrl: URL?) {
    super.init(id: id, userReaction: userReaction, director: director,
               reactionCounters: reactionCounters, created: created, viewed: viewed)
    self.videoLocalUrl = videoLocalUrl
  }
  
  required init(json: JSON) {
    super.init(json: json)
    if json["videoUrl"].string != nil {
      videoUrl = URL(string: json["videoUrl"].stringValue)
    }
  }
  
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if videoUrl != nil {dictionary["videoUrl"] = videoUrl!.absoluteString}
    return dictionary
  }
  
  override func appendTo(multipartFormData: MultipartFormData) {
    super.appendTo(multipartFormData: multipartFormData)
    if videoLocalUrl != nil {
      let videoData = try? Data(contentsOf: videoLocalUrl!)
      if videoData != nil {
        multipartFormData.append(videoData!, withName: Short.shortVideoPart, mimeType: "video/mp4")
      }
    }
  }
}
