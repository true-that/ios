//
//  Media.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Media.java
/// Model for content. See [backend].
class Media: BaseModel {
  // MARK: Properties
  /// Of the media, where it is stored on our backend.
  var url: String?
  
  // Mark: Initialization
  init (url: String?) {
    super.init()
    self.url = url
  }
  
  required init(json: JSON) {
    super.init(json: json)
    url = json["url"].string
  }
  
  override func toDictionary() -> [String : Any] {
    var dictionary = super.toDictionary()
    if url != nil {
      dictionary["url"] = url!
    }
    return dictionary
  }
}
