//
//  ReactableTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat

class ReactableTests: XCTestCase {
  func testJsonSerialization() {
    let reactable = Reactable(id: 1, userReaction: .happy,
                              director: User(id: 1, firstName: "android", lastName: "me no like"),
                              reactionCounters: [.happy: 1200, .sad: 800],
                              created: Date(),
                              viewed: true)
    XCTAssertEqual(reactable, Reactable(json: JSON(from: reactable)))
  }
  
  func testEquals() {
    let now = Date()
    let reactable = Reactable(id: 1, userReaction: .happy,
      director: User(id: 1, firstName: "android", lastName: "me no like"),
      reactionCounters: [.happy: 1200, .sad: 800], created: now,
      viewed: true)
    XCTAssertEqual(reactable, reactable)
    XCTAssertNotEqual(reactable, Reactable(id: nil, userReaction: .happy,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: .sad,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: nil,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: .happy,
                                           director: User(id: 1, firstName: "android2", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: .happy,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1201, .sad: 800], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: .happy,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200], created: now,
                                           viewed: true))
    XCTAssertNotEqual(reactable, Reactable(id: 1, userReaction: .happy,
                                           director: User(id: 1, firstName: "android", lastName: "me no like"),
                                           reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                           viewed: false))
  }
}
