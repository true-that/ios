//
//  Util.swift
//  TrueThat
//
//  Created by Ohad Navon on 25/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

extension Dictionary {
  init(pairs: [Element]) {
    self.init()
    for (k, v) in pairs {
      self[k] = v
    }
  }
  
  func mapPairs<OutKey: Hashable, OutValue>(_ transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
    return Dictionary<OutKey, OutValue>(pairs: try map(transform))
  }
}
