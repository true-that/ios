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
  var reactables: [Reactable] = []
  var actual: [Reactable]?
  var error: NSError?
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(RepertoireApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.reactables.map{JSON(from: $0)}).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    actual = nil
    error = nil
  }
  
  func fetch() {
    _ = RepertoireApi.fetchReactables(for: App.authModule.current!)
      .on(value: {
        self.actual = $0
      })
      .on(failed: {error in
        self.error = error
      })
      .start()
  }
  
  func testSuccessfulFetch() {
    reactables = [Reactable(id: 1, userReaction: .SAD,
                            director: App.authModule.current,
                            reactionCounters: [.SAD: 1000, .HAPPY: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .HAPPY,
                            director: App.authModule.current,
                            reactionCounters: [.SAD: 2000, .HAPPY: 100234],
                            created: Date(), viewed: true)]
    fetch()
    expect(self.actual).toEventually(equal(reactables))
  }
  
  func testFetchMultipleTypes() {
    reactables = [Reactable(id: 1, userReaction: .SAD,
                            director: App.authModule.current,
                            reactionCounters: [.SAD: 1000, .HAPPY: 1234],
                            created: Date(), viewed: false),
                  Scene(id: 2, userReaction: .HAPPY,
                        director: App.authModule.current,
                        reactionCounters: [.SAD: 2000, .HAPPY: 100234],
                        created: Date(), viewed: true, imageSignedUrl: "http://truethat-ipo.jpg")]
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
    stub(condition: isPath(RepertoireApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    reactables = [Reactable(id: 1, userReaction: .SAD,
                            director: App.authModule.current,
                            reactionCounters: [.SAD: 1000, .HAPPY: 1234],
                            created: Date(), viewed: false),
                  Reactable(id: 2, userReaction: .HAPPY,
                            director: App.authModule.current,
                            reactionCounters: [.SAD: 2000, .HAPPY: 100234],
                            created: Date(), viewed: true)]
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
  
  func testBadData() {
    stub(condition: isPath(RepertoireApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
