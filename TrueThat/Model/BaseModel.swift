//
//  BaseModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

/// Abstract data container.
class BaseModel: Equatable, CustomStringConvertible, Hashable {
  /// As stored in our backend.
  var id: Int64?

  var hashValue: Int {
    return description.hashValue
  }

  // MARK: Initiaizliation
  init(id: Int64?) {
    self.id = id
  }

  required init(json: JSON) {
    id = json["id"].int64
  }

  /// Converts model to dictionary to ease JSON use.
  ///
  /// - Returns: The model field names as keys and their respective values as values.
  func toDictionary() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if id != nil {
      dictionary["id"] = id!
    }
    return dictionary
  }

  public var description: String { return "\(toDictionary())" }
}

// MARK: operator overloading
func == (lhs: BaseModel, rhs: BaseModel) -> Bool {
  // Comparing hash value is cheap trick to ensure binary objects (such as URL or Data) will be considered.
  return lhs.hashValue == rhs.hashValue && JSON(from: lhs) == JSON(from: rhs)
}
