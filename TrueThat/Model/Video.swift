//
//  Video.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Video.java
/// A data model of a video. See [backend]
class Video: Media {
  /// Local URL of the video
  var localUrl: URL?
  
  override init(url: String?) {
    super.init(url: url)
  }
  
  init(localUrl: URL?) {
    super.init(url: nil)
    self.localUrl = localUrl
  }
  
  required init(json: JSON) {
    super.init(json: json)
  }
}
