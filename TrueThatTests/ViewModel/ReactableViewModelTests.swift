//
//  ReactableViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble


class ReactableViewModelTests: BaseTests {
  var viewModel: ReactableViewModel!
  var eventCount = 0
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(InteractionApi.path)) {request -> OHHTTPStubsResponse in
      self.eventCount += 1
      let stubData = try! JSON(InteractionEvent(timestamp: nil, userId: nil, reaction: nil,
                                                eventType: nil, reactableId: nil).toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    eventCount = 0
  }
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .SAD,
                              director: User(id: 1, firstName: "Mr", lastName: "Robot", deviceId: "iphone"),
                              reactionCounters: [.SAD: 1000, .HAPPY: 1234],
                              created: Date(), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.model).to(equal(reactable))
    expect(self.viewModel.directorName.value).to(equal(reactable.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("now"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.SAD.emoji))
  }
  
  func testDisplayReactable_commonReactionDisplayed() {
    let reactable = Reactable(id: 1, userReaction: nil, director: nil,
                              reactionCounters: [.SAD: 1, .HAPPY: 2], created: nil, viewed: nil)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.HAPPY.emoji))
  }
  
  func testDisplayReactable_userReactionReactionDisplayed() {
    let reactable = Reactable(id: 1, userReaction: .SAD, director: nil,
                              reactionCounters: [.SAD: 1, .HAPPY: 2], created: nil, viewed: nil)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.SAD.emoji))
  }
  
  func testDisplayReactable_noReactionReactionDisplayed() {
    var reactable = Reactable(id: 1, userReaction: nil, director: nil, reactionCounters: nil,
                              created: nil, viewed: nil)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
    // Now without nil counters
    reactable = Reactable(id: 1, userReaction: nil, director: nil, reactionCounters: [.HAPPY: 0],
                          created: nil, viewed: nil)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
  }
  
  func testInteractionEvents() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Ms", lastName: "Robot", deviceId: "iphone2"),
                              reactionCounters: [.SAD: 3, .HAPPY: 1],
                              created: Date(timeIntervalSinceNow: -60), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    viewModel.didDisplay()
    expect(self.eventCount).toEventually(equal(1))
    // Assert reaction counters in model and view model
    expect(self.viewModel.model.userReaction).to(beNil())
    expect(self.viewModel.model.reactionCounters![.HAPPY]).to(equal(1))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.SAD.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("4"))
    // Fake a detection
    fakeDetectionModule.detect(.HAPPY)
    // Should post a second event
    expect(self.eventCount).toEventually(equal(2))
    // Should update reaction counters and user reaction
    expect(self.viewModel.model.userReaction).to(equal(.HAPPY))
    expect(self.viewModel.model.reactionCounters![.HAPPY]).to(equal(2))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.HAPPY.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("5"))
  }
  
  func testCantInteractAfterDisappear() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Ms", lastName: "Robot", deviceId: "iphone2"),
                              reactionCounters: [.SAD: 1000, .HAPPY: 1234],
                              created: Date(timeIntervalSinceNow: -60), viewed: true)
    viewModel = ReactableViewModel(with: reactable)
    viewModel.didDisplay()
    viewModel.didDisappear()
    fakeDetectionModule.detect(.HAPPY)
    expect(self.eventCount).toNotEventually(equal(1))
  }
}
