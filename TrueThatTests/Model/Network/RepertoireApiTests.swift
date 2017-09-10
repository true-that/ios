//
//  RepertoireApiTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble

class RepertoireApiTests: XCTestCase {
  var scenes: [Scene] = []
  var actual: [Scene]?
  var error: NSError?
  let user = User(id: nil, firstName: nil, lastName: nil, deviceId: nil)

  override func setUp() {
    super.setUp()
    stub(condition: isPath(RepertoireApi.path)) {_ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.scenes.map {JSON(from: $0)}).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    actual = nil
    error = nil
  }

  func fetch() {
    _ = RepertoireApi.fetchScenes(for: user)
      .on(value: {
        self.actual = $0
      })
      .on(failed: {error in
        self.error = error
      })
      .start()
  }

  func testSuccessfulFetch() {
    scenes = [Scene(id: 1, userReaction: .sad,
                    director: user,
                    reactionCounters: [.sad: 1000, .happy: 1234],
                    created: Date(), viewed: false, media: nil),
              Scene(id: 2, userReaction: .happy,
                    director: user,
                    reactionCounters: [.sad: 2000, .happy: 100234],
                    created: Date(), viewed: true, media: nil)]
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testFetchMultipleTypes() {
    scenes = [Scene(id: 1, userReaction: .sad,
                    director: user,
                    reactionCounters: [.sad: 1000, .happy: 1234],
                    created: Date(), viewed: false, media: nil),
              Scene(id: 2, userReaction: .happy,
                    director: user,
                    reactionCounters: [.sad: 2000, .happy: 100234],
                    created: Date(), viewed: true,
                    media: Photo(url: "http://truethat-ipo.jpg"))]
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testEmptyFetch() {
    scenes = []
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testBadResponse() {
    stub(condition: isPath(RepertoireApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                                userInfo: nil))
    }
    scenes = [Scene(id: 1, userReaction: .sad,
                    director: user,
                    reactionCounters: [.sad: 1000, .happy: 1234],
                    created: Date(), viewed: false, media: nil)]
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }

  func testBadData() {
    stub(condition: isPath(RepertoireApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type": "application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
