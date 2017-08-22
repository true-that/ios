//
//  StringExtensionsTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 22/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble

class StringExtensionsTests: XCTestCase {
  func testTitleCase() {
    expect("a".titleCased()).to(equal("A"))
    expect("a b".titleCased()).to(equal("A B"))
    expect("Asta lA visTA".titleCased()).to(equal("Asta La Vista"))
  }
  
  func testSnakeCase() {
    expect("a".snakeCased()).to(equal("a"))
    expect("aB".snakeCased()).to(equal("a_B"))
    expect("iWouldHaveThought".snakeCased()).to(equal("i_Would_Have_Thought"))
    expect("c0meOn".snakeCased()).to(equal("c0me_On"))
  }
  
  func testCamelCase() {
    expect("a_b".camelCased()).to(equal("aB"))
    expect("a3Ro_shoe".camelCased()).to(equal("a3roShoe"))
    expect("STOP".camelCased()).to(equal("stop"))
  }
}
