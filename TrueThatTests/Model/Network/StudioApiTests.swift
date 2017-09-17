//
//  StudioApiTests.swift
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

class StudioApiTests: XCTestCase {
  var scene = Scene(id: 1, director: User(id: 1, firstName: "bon", lastName: "apetit", deviceId: "say-waat"),
                        reactionCounters: [.happy: 1], created: Date(),
                        mediaNodes: [Photo(id: 0, url: "www.mcdonald.com")], edges: nil)

  override func setUp() {
    super.setUp()
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.scene.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
  }

  func testSuccessfulSave() {
    var actual: Scene?
    _ = StudioApi.save(scene: scene)
      .on(value: {
        actual = $0
      })
      .start()
    expect(actual).toEventually(equal(scene))
  }

  func testBadResponse() {
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!, code: 1,
                                         userInfo: nil))
    }
    var responseError: NSError?
    _ = StudioApi.save(scene: scene)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }

  func testBadData() {
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(data: Data(), statusCode: 200,
                          headers: ["Content-Type": "application/json"])
    }
    var responseError: NSError?
    _ = StudioApi.save(scene: scene)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }
}
