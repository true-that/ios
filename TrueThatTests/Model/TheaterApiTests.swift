//
//  TheaterApiSpec.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON


class TheaterApiTests: XCTestCase {
  let timeout = 1.0
  var reactables: [Reactable] = []
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.reactables.map{JSON(from: $0)}).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSuccessfulFetch() {
    let fetchReactablesExpectation = expectation(description: "fetch reactables")
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true)]
      _ = TheaterApi.fetchReactables(for: AuthModule().currentUser)
      .on(value: {
        XCTAssertEqual(self.reactables, $0)
        fetchReactablesExpectation.fulfill()
      })
      .on(failed: {error in
        XCTFail("Should have succeeded")
        fetchReactablesExpectation.fulfill()
      })
    .start()
    waitForExpectations(timeout: timeout, handler: nil)
  }
  
  func testEmptyFetch() {
    let fetchReactablesExpectation = expectation(description: "fetch reactables")
    reactables = []
    _ = TheaterApi.fetchReactables(for: AuthModule().currentUser)
      .on(value: {
        XCTAssertEqual(self.reactables, $0)
        fetchReactablesExpectation.fulfill()
      })
      .on(failed: {error in
        XCTFail("Should have succeeded")
        fetchReactablesExpectation.fulfill()
      })
      .start()
    waitForExpectations(timeout: timeout, handler: nil)
  }
  
  func testBadResponse() {
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    let fetchReactablesExpectation = expectation(description: "bad response fetch reactables")
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true)]
    _ = TheaterApi.fetchReactables(for: AuthModule().currentUser)
      .on(value: {value in
        XCTFail("Should have failed")
        fetchReactablesExpectation.fulfill()
      })
      .on(failed: {error in
        XCTAssertNotNil(error)
        fetchReactablesExpectation.fulfill()
      })
      .start()
    waitForExpectations(timeout: timeout, handler: nil)
  }
  
  func testBadData() {
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    let fetchReactablesExpectation = expectation(description: "bad data fetch reactables")
    _ = TheaterApi.fetchReactables(for: AuthModule().currentUser)
      .on(value: {value in
        XCTFail("Should have failed")
        fetchReactablesExpectation.fulfill()
      })
      .on(failed: {error in
        XCTAssertNotNil(error)
        fetchReactablesExpectation.fulfill()
      })
      .start()
    waitForExpectations(timeout: timeout, handler: nil)
  }
}
