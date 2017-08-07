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
  var responded = Scene(id: 1, userReaction: .happy,
                        director: User(id: 1, firstName: "bon", lastName: "apetit",
                                       deviceId: "say-waat"),
                        reactionCounters: [.happy: 1], created: Date(), viewed: true,
                        imageUrl: "www.mcdonald.com")
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
  }
  
  func testSuccessfulSave() {
    let toSave = Scene(id: 1, userReaction: .happy,
                       director: User(id: 1, firstName: "bon", lastName: "apetit",
                                      deviceId: "say-waat"),
                       reactionCounters: [.happy: 1], created: Date(), viewed: true,
                       imageData: Data())
    var actual: Reactable?
    _ = StudioApi.save(reactable: toSave)
      .on(value: {
        actual = $0
      })
      .start()
    expect(actual).toEventually(equal(responded))
  }
  
  func testBadResponse() {
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    var responseError: NSError?
    _ = StudioApi.save(reactable: responded)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }
  
  func testBadData() {
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    var responseError: NSError?
    _ = StudioApi.save(reactable: responded)
      .on(failed: { error in
        responseError = error
      })
      .start()
    expect(responseError).toEventuallyNot(beNil())
  }
}
