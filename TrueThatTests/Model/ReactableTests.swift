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
import Nimble

class ReactableTests: XCTestCase {
  func testJsonSerialization() {
    let reactable = Reactable(id: 1, userReaction: .happy,
                              director: User(id: 1, firstName: "android", lastName: "me no like"),
                              reactionCounters: [.happy: 1200, .sad: 800],
                              created: Date(),
                              viewed: true)
    expect(reactable).to(equal(Reactable(json: JSON(from: reactable))))
  }
  
  func testEquals() {
    let now = Date()
    let reactable = Reactable(id: 1, userReaction: .happy,
                              director: User(id: 1, firstName: "android", lastName: "me no like"),
                              reactionCounters: [.happy: 1200, .sad: 800], created: now,
                              viewed: true)
    expect(reactable).to(equal(reactable))
    expect(reactable).toNot(equal(Reactable(id: nil, userReaction: .happy,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .sad,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: nil,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android2", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1201, .sad: 800], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200], created: now,
                                            viewed: true)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android", lastName: "me no like"),
                                            reactionCounters: [.happy: 1200, .sad: 800], created: now,
                                            viewed: false)))
  }
  
  func testCanReact() {
    let user = User(id: 1, firstName: "android", lastName: "me no like")
    let sameDirector = Reactable(id: 1, userReaction: nil, director: user, reactionCounters: nil,
                                 created: nil, viewed: nil)
    let alreadyReacted = Reactable(id: 1, userReaction: .happy, director: nil,
                                   reactionCounters: nil, created: nil, viewed: nil)
    let noDirector = Reactable(id: 1, userReaction: nil, director: nil, reactionCounters: nil,
                               created: nil, viewed: nil)
    let withDirectDidntReact = Reactable(id: 1, userReaction: nil, director: user,
                                         reactionCounters: nil, created: nil, viewed: nil)
    expect(sameDirector.canReact(user: user)).to(beFalse())
    expect(alreadyReacted.canReact(user: user)).to(beFalse())
    expect(noDirector.canReact(user: user)).to(beTrue())
    expect(withDirectDidntReact.canReact(user: User(id: 2, firstName: "senior",
                                                    lastName: "cozashvili"))).to(beTrue())
  }
}
