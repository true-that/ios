//
//  InteractionEventTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat
import Nimble

class InteractionEventTests: XCTestCase {
  func testJsonSerialization() {
    let interactionEvent = InteractionEvent(timestamp: Date(), userId: 1, reaction: .happy,
                                            eventType: .reactableReaction, reactableId: 1)
    expect(interactionEvent).to(equal(InteractionEvent(json: JSON(from: interactionEvent))))
  }
}
