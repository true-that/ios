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
                              director: User(id: 1, firstName: "android", lastName: "me no like",
                                             deviceId: "iphone"),
                              reactionCounters: [.happy: 1200, .sad: 800],
                              created: Date(),
                              viewed: true, media: nil)
    expect(reactable).to(equal(Reactable(json: JSON(from: reactable))))
  }
  
  func testEquals() {
    let now = Date()
    let reactable = Reactable(id: 1, userReaction: .happy,
                              director: User(id: 1, firstName: "android", lastName: "me no like",
                                             deviceId: "iphone"),
                              reactionCounters: [.happy: 1200, .sad: 800], created: now,
                              viewed: true, media: nil)
    expect(reactable).to(equal(reactable))
    expect(reactable).toNot(equal(Reactable(id: nil, userReaction: .happy,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .sad,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: nil,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android2",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1201, .sad: 800],
                                            created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200], created: now,
                                            viewed: true, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: false, media: nil)))
    expect(reactable).toNot(equal(Reactable(id: 1, userReaction: .happy,
                                            director: User(id: 1, firstName: "android",
                                                           lastName: "me no like",
                                                           deviceId: "iphone"),
                                            reactionCounters: [.happy: 1200, .sad: 800],
                                            created: now,
                                            viewed: false, media: Photo(url: ""))))
  }
  
  func testCanReact() {
    let user = User(id: 1, firstName: "android", lastName: "me no like", deviceId: "iphone")
    let sameDirector = Reactable(id: 1, userReaction: nil, director: user, reactionCounters: nil,
                                 created: nil, viewed: nil, media: nil)
    let alreadyReacted = Reactable(id: 1, userReaction: .happy, director: nil,
                                   reactionCounters: nil, created: nil, viewed: nil, media: nil)
    let noDirector = Reactable(id: 1, userReaction: nil, director: nil, reactionCounters: nil,
                               created: nil, viewed: nil, media: nil)
    let withDirectDidntReact = Reactable(id: 1, userReaction: nil, director: user,
                                         reactionCounters: nil, created: nil, viewed: nil,
                                         media: nil)
    expect(sameDirector.canReact(user: user)).to(beFalse())
    expect(alreadyReacted.canReact(user: user)).to(beFalse())
    expect(noDirector.canReact(user: user)).to(beTrue())
    expect(withDirectDidntReact.canReact(user: User(id: 2, firstName: "senior",
                                                    lastName: "cozashvili", deviceId: "103")))
      .to(beTrue())
  }
  
  func testUpdateReactionCounters() {
    let reaction = Emotion.happy
    let nilCounters = Reactable(id: 1, userReaction: nil, director: nil, reactionCounters: nil,
                                 created: nil, viewed: nil, media: nil)
    let firstReactionOfType = Reactable(id: 2, userReaction: nil, director: nil,
                                        reactionCounters: [.sad: 1], created: nil, viewed: nil,
                                        media: nil)
    let shouldIncrement = Reactable(id: 3, userReaction: nil, director: nil,
                                    reactionCounters: [.happy: 2], created: nil, viewed: nil,
                                    media: nil)
    // Increment counters
    nilCounters.updateReactionCounters(with: reaction)
    firstReactionOfType.updateReactionCounters(with: reaction)
    shouldIncrement.updateReactionCounters(with: reaction)
    // Expected behaviour
    expect(nilCounters.reactionCounters?[reaction]).to(equal(1))
    expect(firstReactionOfType.reactionCounters?[reaction]).to(equal(1))
    expect(shouldIncrement.reactionCounters?[reaction]).to(equal(3))
  }
}
