//
//  Photo.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Photo.java
/// A data model of a photo. See [backend]
class Photo: Media {
  /// Data of the image.
  var data: Data?
  
  override init(url: String?) {
    super.init(url: url)
  }

  init(data: Data?) {
    super.init(url: nil)
    self.data = data
  }
  
  required init(json: JSON) {
    super.init(json: json)
  }
}
