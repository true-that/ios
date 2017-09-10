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
  
  func fetch() {
    _ = TheaterApi.fetchReactables(for: App.authModule.current!)
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
                            director: User(id: 1, firstName: "copa", lastName: "cabana",
                                           deviceId: "android"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false, media: Photo(url: "brazil.jpg")),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow",
                                           deviceId: "android"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true, media: Photo(url: "carnaval.jpg"))]
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testFetchMultipleTypes() {
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana",
                                           deviceId: "android"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false, media: Photo(url: "brazil.jpg")),
                  Reactable(id: 2, userReaction: .happy,
                            director: User(id: 1, firstName: "barry", lastName: "manilow",
                                           deviceId: "android"),
                            reactionCounters: [.sad: 2000, .happy: 100234],
                            created: Date(), viewed: true,
                            media: Video(url: "http://truethat-ipo.mp4"))]
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testEmptyFetch() {
    reactables = []
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testBadResponse() {
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                                userInfo: nil))
    }
    reactables = [Reactable(id: 1, userReaction: .sad,
                            director: User(id: 1, firstName: "copa", lastName: "cabana",
                                           deviceId: "android"),
                            reactionCounters: [.sad: 1000, .happy: 1234],
                            created: Date(), viewed: false, media: nil)]
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
