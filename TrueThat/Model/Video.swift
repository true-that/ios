//
//  Video.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Video.java
/// A data model of a video. See [backend]
class Video: Media {

  /// Local URL of the video
  var localUrl: URL?

  // MARK: Initialization
  override init(id: Int64?, url: String?) {
    super.init(id: id, url: url)
  }

  init(localUrl: URL?) {
    super.init(id: nil, url: nil)
    self.localUrl = localUrl
  }

  required init(json: JSON) {
    super.init(json: json)
  }

  override func appendTo(multipartFormData: MultipartFormData, withName partName: String) {
    super.appendTo(multipartFormData: multipartFormData, withName: partName)
    if localUrl != nil {
      let data = try? Data(contentsOf: localUrl!)
      if data != nil {
        multipartFormData.append(data!, withName: partName, mimeType: "video/mp4")
      }
    }
  }

  override var hashValue: Int {
    let superHash = super.hashValue
    if localUrl != nil {
      return 31 &* superHash &+ localUrl!.hashValue
    }
    return superHash
  }
}
