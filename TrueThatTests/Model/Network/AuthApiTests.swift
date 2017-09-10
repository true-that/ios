//
//  AuthApiTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble

class AuthApiTests: XCTestCase {
  var responded = User(id: 1, firstName: "Bill", lastName: "Burr", deviceId: "iPhone-3")

  override func setUp() {
    super.setUp()
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
  }

  func testSuccessfulAuth() {
    var actual: User?
    _ = AuthApi.auth(for: responded)
      .on(value: {
        actual = $0
      })
      .start()
    expect(actual).toEventually(equal(responded))
  }

  func testBadResponse() {
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                                userInfo: nil))
    }
    var responseError: NSError?
    _ = AuthApi.auth(for: responded)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }

  func testBadData() {
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type": "application/json"])
    }
    var responseError: NSError?
    _ = AuthApi.auth(for: responded)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }
}
