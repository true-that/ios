//
//  SceneViewModelTests.swift
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

class SceneViewModelTests: BaseTests {
  var viewModel: SceneViewModel!
  var viewModelDelegate: TestsSceneViewDelegate!
  var eventCount = 0

  override func setUp() {
    super.setUp()
    stub(condition: isPath(InteractionApi.path)) { request -> OHHTTPStubsResponse in
      self.eventCount += 1
      let requestEvent = InteractionEvent(json: JSON(Data(fromStream: request.httpBodyStream!)))
      let data = try? JSON(from: requestEvent).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    eventCount = 0
  }

  func initViewModel(with scene: Scene) {
    viewModelDelegate = TestsSceneViewDelegate()
    viewModel = SceneViewModel(with: scene)
    viewModel.delegate = viewModelDelegate
  }

  func testDisplayScene() {
    let scene = Scene(id: 1, userReaction: .disgust,
                      director: User(id: 1, firstName: "Mr", lastName: "Robot",
                                     deviceId: "iphone"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    initViewModel(with: scene)
    expect(self.viewModel.model).to(equal(scene))
    expect(self.viewModel.directorName.value).to(equal(scene.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("now"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.disgust.emoji))
    viewModel.didDisplay()
    expect(self.viewModel.optionsButtonHidden.value).to(beFalse())
  }

  func testDisplayScene_commonReactionDisplayed() {
    let scene = Scene(id: 1, userReaction: nil, director: nil,
                      reactionCounters: [.disgust: 1, .happy: 2], created: nil, viewed: nil,
                      media: nil)
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
  }

  func testDisplayScene_userReactionReactionDisplayed() {
    let scene = Scene(id: 1, userReaction: .disgust, director: nil,
                      reactionCounters: [.disgust: 1, .happy: 2], created: nil, viewed: nil,
                      media: nil)
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.disgust.emoji))
  }

  func testDisplayScene_noReactionReactionDisplayed() {
    var scene = Scene(id: 1, userReaction: nil, director: nil, reactionCounters: nil,
                      created: nil, viewed: nil, media: nil)
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
    // Now without nil counters
    scene = Scene(id: 1, userReaction: nil, director: nil, reactionCounters: [.happy: 0],
                  created: nil, viewed: nil, media: nil)
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
  }

  func testInteractionEvents() {
    let scene = Scene(id: 1, userReaction: nil,
                      director: User(id: 1, firstName: "Ms", lastName: "Robot",
                                     deviceId: "iphone2"),
                      reactionCounters: [.disgust: 3, .happy: 1],
                      created: Date(timeIntervalSinceNow: -60), viewed: false, media: nil)
    initViewModel(with: scene)
    viewModel.didDisplay()
    expect(self.eventCount).toEventually(equal(1))
    // Assert reaction counters in model and view model
    expect(self.viewModel.model.userReaction).to(beNil())
    expect(self.viewModel.model.reactionCounters![.happy]).to(equal(1))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.disgust.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("4"))
    // Fake a detection
    fakeDetectionModule.detect(.happy)
    // Should post a second event
    expect(self.eventCount).toEventually(equal(2))
    // Should update reaction counters and user reaction
    expect(self.viewModel.model.userReaction).to(equal(.happy))
    expect(self.viewModel.model.reactionCounters![.happy]).to(equal(2))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("5"))
  }

  func testReport() {
    let scene = Scene(id: 1, userReaction: nil,
                      director: User(id: 1, firstName: "Ms", lastName: "Robot",
                                     deviceId: "iphone2"),
                      reactionCounters: [.disgust: 3, .happy: 1],
                      created: Date(timeIntervalSinceNow: -60), viewed: false, media: nil)
    initViewModel(with: scene)
    viewModel.didDisplay()
    // Wait for view event
    expect(self.eventCount).toEventually(equal(1))
    viewModel.didReport()
    expect(self.viewModel.reportHidden.value).to(beTrue())
    // Wait for report event
    expect(self.eventCount).toEventually(equal(2))
    expect(self.viewModelDelegate.didShow).toEventually(beTrue())
  }

  func testCantReportBeforeView() {
    let scene = Scene(id: 1, userReaction: nil,
                      director: User(id: 1, firstName: "Ms", lastName: "Robot",
                                     deviceId: "iphone2"),
                      reactionCounters: [.disgust: 3, .happy: 1],
                      created: Date(timeIntervalSinceNow: -60), viewed: false, media: nil)
    initViewModel(with: scene)
    viewModel.didReport()
    expect(self.viewModelDelegate.didShow).toNotEventually(beTrue())
  }

  func testCantInteractAfterDisappear() {
    let scene = Scene(id: 1, userReaction: nil,
                      director: User(id: 1, firstName: "Ms", lastName: "Robot",
                                     deviceId: "iphone2"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(timeIntervalSinceNow: -60), viewed: true, media: nil)
    initViewModel(with: scene)
    viewModel.didDisplay()
    viewModel.didDisappear()
    fakeDetectionModule.detect(.happy)
    expect(self.eventCount).toNotEventually(equal(1))
  }

  class TestsSceneViewDelegate: SceneViewDelegate {
    var didShow = false

    func animateReactionImage() {
    }

    func show(alert: String, withTitle: String, okAction: String) {
      didShow = true
    }
  }
}
