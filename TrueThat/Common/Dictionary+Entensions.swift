//
//  Util.swift
//  TrueThat
//
//  Created by Ohad Navon on 25/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

extension Dictionary {
  
  /// Initializaes a dictionary from a collection of pairs.
  ///
  /// - Parameter pairs: to create a dictionary from.
  init(pairs: [Element]) {
    self.init()
    for (k, v) in pairs {
      self[k] = v
    }
  }
  
  
  /// Maps dictionary entries into another dictionary by applying `transform`.
  ///
  /// - Parameter transform: a transformation to apply for `self`.
  /// - Returns: a new dictionary of the transformed `self`.
  /// - Throws: pairs of the transformed dictionary.
  func mapPairs<OutKey: Hashable, OutValue>(_ transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
    return Dictionary<OutKey, OutValue>(pairs: try map(transform))
  }
}
