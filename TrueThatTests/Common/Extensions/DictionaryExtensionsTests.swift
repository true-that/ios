//
//  DictionaryExtensionsTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 22/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble

class DictionaryExtensionsTests: XCTestCase {
  func testPairsInit() {
    expect(Dictionary(pairs: [("a", 1), ("b", 2)])).to(equal(["a": 1, "b": 2]))
  }

  func testMapPairs() {
    let dict = ["a": 1, "b": 2]
    expect(dict.mapPairs { key, val in
      ("\(key)-\(val)", val + 1)
    }).to(equal(["a-1": 2, "b-2": 3]))
  }
}
