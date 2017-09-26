//
//  Media.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/Media.java
/// Model for content. See [backend].
class Media: BaseModel {
  // MARK: Properties
  /// Of the media, where it is stored on our backend.
  var url: String?

  /// Whether the media is prepared for being sent over the network.
  var isPrepared = false

  /// A delegate to notify once this media is ready for network requests.
  var delegate: MediaPreparedDelegate?

  // Mark: Initialization
  init(id: Int64?, url: String?) {
    super.init(id: id)
    self.url = url
  }

  required init(json: JSON) {
    super.init(json: json)
    if id == nil {
      App.log.warning("Missing id.")
    }
    url = json["url"].string
    if url == nil {
      App.log.warning("Missing url.")
    }
  }

  static func instantiate(with json: JSON) -> Media? {
    guard let type = json["type"].string else {
      App.log.warning("Failed to deserialize Media. Missing type.")
      return nil
    }
    switch type {
    case String(describing: Media.self):
      return Media(json: json)
    case String(describing: Photo.self):
      return Photo(json: json)
    case String(describing: Video.self):
      return Video(json: json)
    default:
      App.log.warning("Failed to deserialize Media. Illegal type (=\(type))?")
      return nil
    }
  }

  // Mark: JSON
  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if url != nil {
      dictionary["url"] = url!
    }
    dictionary["type"] = String(describing: type(of: self))
    return dictionary
  }

  // MARK: Network

  /// Appends media data to a multipart request
  ///
  /// - Parameter multipartFormData: to append to
  func appendTo(multipartFormData: MultipartFormData) {}
}

/// Used to notify `Scene` objects that their media fields are ready for network requests.
protocol MediaPreparedDelegate {

  /// Invoked once a media content is prepared for network requests.
  func didPrepare()
}
