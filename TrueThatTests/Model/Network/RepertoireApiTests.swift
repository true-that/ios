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
  var scene: Scene!

  override func setUp() {
    super.setUp()
    stub(condition: isPath(RepertoireApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.scenes.map { JSON(from: $0) }).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    scene = Scene(id: 1, director: self.user, reactionCounters: nil, created: nil, mediaNodes: nil, edges: nil)
    scenes = []
    actual = nil
    error = nil
  }

  func fetch() {
    _ = RepertoireApi.fetchScenes(for: user)
      .on(value: {
        self.actual = $0
      })
      .on(failed: { error in
        self.error = error
      })
      .start()
  }

  func testSuccessfulFetch() {
    scenes = [scene, scene]
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testEmptyFetch() {
    scenes = []
    fetch()
    expect(self.actual).toEventually(equal(scenes))
  }

  func testBadResponse() {
    stub(condition: isPath(RepertoireApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                         userInfo: nil))
    }
    scenes = [scene]
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }

  func testBadData() {
    stub(condition: isPath(RepertoireApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(data: Data(), statusCode: 200,
                          headers: ["Content-Type": "application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
