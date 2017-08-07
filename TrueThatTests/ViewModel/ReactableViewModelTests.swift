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
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "Mr", lastName: "Robot", deviceId: "iphone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.model).to(equal(reactable))
    expect(self.viewModel.directorName.value).to(equal(reactable.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("now"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.sad.emoji))
  }
  
  func testDisplayReactable_commonReactionDisplayed() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Ms", lastName: "Robot", deviceId: "iphone2"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(timeIntervalSinceNow: -60), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.model).to(equal(reactable))
    expect(self.viewModel.directorName.value).to(equal(reactable.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("1m ago"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
  }
  
  func testInteractionEvents() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Ms", lastName: "Robot", deviceId: "iphone2"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(timeIntervalSinceNow: -60), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    viewModel.didDisplay()
    expect(self.eventCount).toEventually(equal(1))
    fakeDetectionModule.detect(.happy)
    expect(self.eventCount).toEventually(equal(2))
  }
  
  func testCantInteractAfterDisappear() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Ms", lastName: "Robot", deviceId: "iphone2"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(timeIntervalSinceNow: -60), viewed: true)
    viewModel = ReactableViewModel(with: reactable)
    viewModel.didDisplay()
    viewModel.didDisappear()
    fakeDetectionModule.detect(.happy)
    expect(self.eventCount).toNotEventually(equal(1))
  }
}
