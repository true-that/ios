//
//  InteractionApiTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble


class InteractionApiTests: XCTestCase {
  var interaction: InteractionEvent!
  var actual: InteractionEvent?
  var error: NSError?
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(InteractionApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(from: self.interaction).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    interaction = nil
    actual = nil
    error = nil
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func fetch() {
    _ = InteractionApi.save(interaction: interaction)
      .on(value: {
        self.actual = $0
      })
      .on(failed: {error in
        self.error = error
      })
      .start()
  }
  
  func testSuccessfulSave() {
    interaction = InteractionEvent(timestamp: Date(), userId: 1, reaction: .happy,
                                   eventType: .reaction, reactableId: 1)
    fetch()
    expect(self.actual).toEventually(equal(interaction))
    interaction = InteractionEvent(timestamp: Date(), userId: 2, reaction: nil,
                                   eventType: .view, reactableId: 2)
    fetch()
    expect(self.actual).toEventually(equal(interaction))
  }
  
  func testBadResponse() {
    stub(condition: isPath(InteractionApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    interaction = InteractionEvent(timestamp: Date(), userId: 1, reaction: .happy,
                                   eventType: .reaction, reactableId: 1)
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
  
  func testBadData() {
    interaction = InteractionEvent(timestamp: Date(), userId: 1, reaction: .happy,
                                   eventType: .reaction, reactableId: 1)
    stub(condition: isPath(InteractionApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    fetch()
    expect(self.error).toEventuallyNot(beNil())
  }
}
