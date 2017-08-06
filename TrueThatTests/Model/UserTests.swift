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
import Nimble

class UserTests: XCTestCase {
  func testJsonSerialization() {
    let user = User(id: 1, firstName: "aba", lastName: "ganuv", deviceId: "rezah")
    expect(user).to(equal(User(json: JSON(from: user))))
  }
  
  func testIsAuthOk() {
    var user = User(id: 1, firstName: "aba", lastName: "ganuv", deviceId: "rezah")
    expect(user.isAuthOk).to(beTrue())
    user = User(id: nil, firstName: "aba", lastName: "ganuv", deviceId: "rezah")
    expect(user.isAuthOk).to(beFalse())
    user = User(id: 1, firstName: nil, lastName: "ganuv", deviceId: "rezah")
    expect(user.isAuthOk).to(beFalse())
    user = User(id: 1, firstName: "aba", lastName: nil, deviceId: "rezah")
    expect(user.isAuthOk).to(beFalse())
  }
}
