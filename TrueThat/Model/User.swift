//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/model/User.java
/// Model for our sassy users. See [backend].
class User: BaseModel {

  /// How her mother calls her.
  var firstName: String?
  /// How his friends calls him.
  var lastName: String?
  /// For future authentication.
  var deviceId: String?
  /// Whether this user instance is authenticated from a client perspective.
  public var isAuthOk: Bool {
    return id != nil && firstName != nil && lastName != nil
  }

  // Mark: Initialization
  init(id: Int64?, firstName: String?, lastName: String?, deviceId: String?) {
    super.init(id: id)
    self.firstName = firstName
    self.lastName = lastName
    self.deviceId = deviceId
  }

  required init(json: JSON) {
    super.init(json: json)
    firstName = json["firstName"].string
    lastName = json["lastName"].string
  }

  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if firstName != nil {
      dictionary["firstName"] = firstName!
    }
    if lastName != nil {
      dictionary["lastName"] = lastName!
    }
    return dictionary
  }
}

// MARK: Computed Properties
extension User {
  /// Display name for UI.
  var displayName: String {
    if firstName == nil || lastName == nil {
      return ""
    }
    return "\(firstName!) \(lastName!)".titleCased()
  }
}
