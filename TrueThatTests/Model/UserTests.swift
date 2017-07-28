//
//  UserTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat

class UserTests: XCTestCase {
  func testJsonSerialization() {
    let user = User(id: 1, firstName: "aba", lastName: "ganuv")
    XCTAssertEqual(user, User(json: JSON(from: user)))
  }
}
