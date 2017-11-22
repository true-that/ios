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
  /// How his army friends calls him.
  var lastName: String?
  /// For future authentication.
  var deviceId: String?
  /// Phone number, so that we can find it in other user's contact lists.
  var phoneNumber: String?
  /// Whether this user instance is authenticated from a client perspective.
  public var isAuthOk: Bool {
    return id != nil && firstName != nil && lastName != nil
  }

  // Mark: Initialization
  init(id: Int64?, firstName: String?, lastName: String?, deviceId: String?, phoneNumber: String?) {
    super.init(id: id)
    self.firstName = firstName
    self.lastName = lastName
    self.deviceId = deviceId
    self.phoneNumber = phoneNumber
  }

  required init(json: JSON) {
    super.init(json: json)
    if id == nil {
      App.log.warning("Missing id.")
    }
    firstName = json["firstName"].string
    if firstName == nil {
      App.log.warning("Missing first name.")
    }
    lastName = json["lastName"].string
    if lastName == nil {
      App.log.warning("Missing last name.")
    }
    deviceId = json["deviceId"].string
    phoneNumber = json["phoneNumber"].string
  }

  override func toDictionary() -> [String: Any] {
    var dictionary = super.toDictionary()
    if firstName != nil {
      dictionary["firstName"] = firstName!
    }
    if lastName != nil {
      dictionary["lastName"] = lastName!
    }
    if deviceId != nil {
      dictionary["deviceId"] = deviceId!
    }
    if phoneNumber != nil {
      dictionary["phoneNumber"] = phoneNumber!
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
