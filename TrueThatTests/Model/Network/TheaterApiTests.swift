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
  var scenes: [Scene] = []
  var actual: [Scene]?
  var error: NSError?
  let director = User(id: 1, firstName: "copa", lastName: "cabana", deviceId: "android", phoneNumber: nil)

  override func setUp() {
    super.setUp()
    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.scenes.map { JSON(from: $0) }).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    actual = nil
    error = nil
  }

  func fetch() {
    _ = TheaterApi.fetchScenes(for: App.authModule.current!)
      .on(value: {
        self.actual = $0
      })
      .on(failed: { error in
        self.error = error
      })
      .start()
  }

  func testSuccessfulFetch() {
    scenes = [
      Scene(id: 1, director: director,
            reactionCounters: [.disgust: 1000, .happy: 1234],
            created: Date(), mediaNodes: [Photo(id: 0, url: "brazil.jpg")], edges: nil),
      Scene(id: 2, director: director,
            reactionCounters: [.disgust: 2000, .happy: 100_234],
            created: Date(), mediaNodes: [Photo(id: 0, url: "carnaval.jpg")], edges: nil),
    ]
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testFetchMultipleTypes() {
    scenes = [
      Scene(id: 1, director: director,
            reactionCounters: [.disgust: 1000, .happy: 1234],
            created: Date(), mediaNodes: [Photo(id: 0, url: "brazil.jpg")], edges: nil),
      Scene(id: 2, director: director,
            reactionCounters: [.disgust: 2000, .happy: 100_234],
            created: Date(), mediaNodes: [Video(id: 0, url: "http://truethat-ipo.mp4")], edges: nil),
    ]
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testEmptyFetch() {
    scenes = []
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testBadResponse() {
    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                         userInfo: nil))
    }
    scenes = [Scene(id: 1, director: director,
                    reactionCounters: [.disgust: 1000, .happy: 1234], created: Date(), mediaNodes: nil, edges: nil)]
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }

  func testBadData() {
    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(data: Data(), statusCode: 200,
                          headers: ["Content-Type": "application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
