//
//  TheaterApiTests.swift
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
import Nimble


class TheaterApiTests: XCTestCase {
  var reactables: [Reactable] = []
  var actual: [Reactable]?
  var error: NSError?
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.reactables.map{JSON(from: $0)}).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    actual = nil
    error = nil
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func fetch() {
    _ = TheaterApi.fetchReactables(for: AuthModule().currentUser)
      .on(value: {
        self.actual = $0
      })
      .on(failed: {error in
        self.error = error
      })
      .start()
  }
  
  func testSuccessfulFetch() {
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true)]
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testFetchMultipleTypes() {
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false),
                  Scene(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true, imageUrl: "http://truethat-ipo.jpg")]
    fetch()
    expect(self.actual).toEventually(equal(reactables))
    expect(self.actual![1]).toEventually(beAnInstanceOf(Scene.self))
  }
  
  func testEmptyFetch() {
    reactables = []
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testBadResponse() {
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true)]
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
  
  func testBadData() {
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
