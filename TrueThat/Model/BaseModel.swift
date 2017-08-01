//
//  BaseModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON


/// Abstract data container.
class BaseModel: Equatable, CustomStringConvertible {
  init() {}
  
  required init(json: JSON) {}
  
  
  /// Converts model to dictionary to ease JSON use.
  ///
  /// - Returns: The model field names as keys and their respective values as values.
  func toDictionary() -> [String: Any] {
    return [:]
  }
  
  public var description: String { return "\(toDictionary())" }
}

// MARK: operator overloading
func == (lhs: BaseModel, rhs: BaseModel) -> Bool {
  return JSON(from: lhs) == JSON(from: rhs)
}
