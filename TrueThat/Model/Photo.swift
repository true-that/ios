//
//  Photo.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Photo.java
/// A data model of a photo. See [backend]
class Photo: Media {
  
  /// Data of the image.
  var data: Data?

  // MARK: Initiaizliation
  override init(id: Int64?, url: String?) {
    super.init(id: id, url: url)
  }

  init(data: Data?) {
    super.init(id: nil, url: nil)
    self.data = data
  }

  required init(json: JSON) {
    super.init(json: json)
  }

  override func appendTo(multipartFormData: MultipartFormData, withName partName: String) {
    super.appendTo(multipartFormData: multipartFormData, withName: partName)
    if data != nil {
      multipartFormData.append(data!, withName: partName, mimeType: "image/jpg")
    }
  }
  
  override var hashValue: Int {
    let superHash = super.hashValue
    if data != nil {
      return 31 * superHash + data!.hashValue
    }
    return superHash
  }
}
