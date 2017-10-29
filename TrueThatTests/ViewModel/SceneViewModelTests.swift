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
  let photo1 = Photo(id: 1, url: "1")
  let photo2 = Photo(id: 2, url: "2")
  let photo3 = Photo(id: 3, url: "3")
  let edge1to2 = Edge(sourceId: 1, targetId: 2, reaction: .omg)
  let edge1to3 = Edge(sourceId: 1, targetId: 3, reaction: .happy)
  let edge2to3 = Edge(sourceId: 2, targetId: 3, reaction: .omg)
  let director = User(id: 1, firstName: "Mr", lastName: "Bean", deviceId: "iphone1", phoneNumber: "+4985734345")
  var scene: Scene!
  var viewModel: SceneViewModel!
  var viewModelDelegate: TestsSceneViewDelegate!
  var eventCount = 0
  var lastEvent: InteractionEvent!

  override func setUp() {
    super.setUp()
    SceneViewModel.detetionDelaySeconds = 0.01
    stub(condition: isPath(InteractionApi.path)) { request -> OHHTTPStubsResponse in
      self.lastEvent = InteractionEvent(json: JSON(Data(fromStream: request.httpBodyStream!)))
      let data = try? JSON(from: self.lastEvent).rawData()
      self.eventCount += 1
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    eventCount = 0
    scene = Scene(id: 1, director: director, reactionCounters: [.disgust: 1000, .happy: 1234], created: Date(),
                  mediaNodes: [photo1], edges: nil)
  }

  func initViewModel(with scene: Scene) {
    viewModelDelegate = TestsSceneViewDelegate()
    viewModel = SceneViewModel(with: scene)
    viewModelDelegate.viewModel = viewModel
    viewModel.delegate = viewModelDelegate
    viewModel.didAppear()
  }

  func testDisplayScene() {
    initViewModel(with: scene)
    // Display proper scene
    expect(self.viewModel.scene).to(equal(scene))
    expect(self.viewModel.directorName.value).to(equal(scene.director?.displayName))
    // Format time ago
    expect(self.viewModel.timeAgo.value).to(equal("now"))
    // Sum and truncate reactions counters
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
    viewModel.didDownloadMedia()
    expect(self.viewModel.optionsButtonHidden.value).to(beFalse())
    // UI should display the right media
    expect(self.viewModelDelegate.displayed).to(equal(scene.mediaNodes![0]))
  }

  func testDisplayScene_commonReactionDisplayed() {
    scene.reactionCounters = [.disgust: 1, .happy: 2]
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
  }

  func testDisplayScene_nilReactionCounters() {
    scene.reactionCounters = nil
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
  }

  func testDisplayScene_zeroReactionCounters() {
    scene.reactionCounters = [.happy: 0, .omg: 0]
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(""))
    expect(self.viewModel.reactionsCount.value).to(equal(""))
  }

  func testMultipleReactions() {
    let reaction1 = Emotion.happy
    let reaction2 = Emotion.omg
    let reaction3 = Emotion.omg
    scene.reactionCounters = [reaction3: 2]
    initViewModel(with: scene)
    expect(self.viewModel.reactionEmoji.value).to(equal(reaction3.emoji))
    viewModel.didDownloadMedia()
    // Expect a view event to be sent
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Fake a detection
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(reaction1)
    // Should post a second event
    expect(self.eventCount).toEventually(equal(2))
    expect(self.lastEvent.eventType).to(equal(EventType.reaction))
    expect(self.lastEvent.reaction).to(equal(reaction1))
    // Should animate the detected reaction
    expect(self.viewModelDelegate.animatedImage).to(beTrue())
    viewModelDelegate.animatedImage = false
    // Should display it to the user
    expect(self.viewModel.reactionEmoji.value).to(equal(reaction1.emoji))
    // Fake a detection of reaction 2
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(reaction2)
    // Should post a second event
    expect(self.eventCount).toEventually(equal(3))
    expect(self.lastEvent.eventType).to(equal(EventType.reaction))
    expect(self.lastEvent.reaction).to(equal(reaction2))
    // Should animate it and display it to the user
    expect(self.viewModelDelegate.animatedImage).to(beTrue())
    viewModelDelegate.animatedImage = false
    expect(self.viewModel.reactionEmoji.value).to(equal(reaction2.emoji))
    // Fake another detection of reaction 2
    fakeDetectionModule.detect(reaction2)
    // Should not have an effect
    expect(self.viewModelDelegate.animatedImage).toNotEventually(beTrue())
    expect(self.eventCount).toNotEventually(equal(4))
    // Fake a detection of reaction 1
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(reaction1)
    // Should not post an event
    expect(self.eventCount).toNotEventually(equal(4))
    // Should animate it and display it to the user
    expect(self.viewModelDelegate.animatedImage).to(beTrue())
    viewModelDelegate.animatedImage = false
    expect(self.viewModel.reactionEmoji.value).to(equal(reaction1.emoji))
  }

  func testReactionIgnored_withMultipleNextMedia() {
    scene = Scene(id: 1, director: director, reactionCounters: [edge1to2.reaction!: 1], created: Date(),
                 mediaNodes: [photo1, photo2, photo3], edges: [edge1to2, edge1to3])
    initViewModel(with: scene)
    viewModel.didDownloadMedia()
    // Expect a view event to be sent
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Fake a detection
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(edge1to2.reaction!, mostLikely: false)
    // Should not post a reaction event
    expect(self.eventCount).toNotEventually(equal(2))
  }

  func testReactionIgnored_withoutNextMedia() {
    scene = Scene(id: 1, director: director, reactionCounters: [edge1to2.reaction!: 1], created: Date(),
                  mediaNodes: [photo1, photo2], edges: [edge1to2])
    initViewModel(with: scene)
    viewModel.didDownloadMedia()
    // Expect a view event to be sent
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Fake a detection
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(edge1to3.reaction!, mostLikely: false)
    // Should not post a reaction event
    expect(self.eventCount).toNotEventually(equal(2))
  }

  func testReactionDetected_withSingleNextMedia() {
    scene = Scene(id: 1, director: director, reactionCounters: [edge1to2.reaction!: 1], created: Date(),
                  mediaNodes: [photo1, photo2], edges: [edge1to2])
    initViewModel(with: scene)
    viewModel.didDownloadMedia()
    // Expect a view event to be sent
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Fake a detection
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(edge1to2.reaction!, mostLikely: false)
    // Should post a reaction event
    expect(self.eventCount).toEventually(equal(2))
  }

  func testInteractionEvents() {
    scene.reactionCounters = [.happy: 1, .disgust: 3]
    initViewModel(with: scene)
    viewModel.didDownloadMedia()
    // Asserting the interaction event
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.userId).to(equal(self.scene.director!.id!))
    expect(self.lastEvent.reaction).to(beNil())
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    expect(self.lastEvent.sceneId).to(equal(self.scene.id!))
    expect(self.lastEvent.mediaId).to(equal(self.scene.mediaNodes![0].id!))
    // Assert reaction counters in model and view model
    expect(self.viewModel.scene.reactionCounters![.happy]).to(equal(1))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.disgust.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("4"))
    let reaction = Emotion.happy
    // Fake a detection
    expect(App.detecionModule.delegate).toEventually(beIdenticalTo(viewModel))
    fakeDetectionModule.detect(reaction)
    // Should post a second event
    expect(self.eventCount).toEventually(equal(2))
    expect(self.lastEvent.reaction).to(equal(reaction))
    expect(self.lastEvent.eventType).to(equal(EventType.reaction))
    // Should update reaction counters and user reaction
    expect(self.viewModel.scene.reactionCounters![.happy]).to(equal(2))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
    expect(self.viewModel.reactionsCount.value).to(equal("5"))
  }

  func testReport() {
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
    let scene = Scene(id: 1, director: director, reactionCounters: [.disgust: 3, .happy: 1],
                      created: Date(timeIntervalSinceNow: -60), mediaNodes: nil, edges: nil)
    initViewModel(with: scene)
    viewModel.didReport()
    expect(self.viewModelDelegate.didShow).toNotEventually(beTrue())
  }

  func testCantInteractAfterDisappear() {
    initViewModel(with: scene)
    viewModel.didDownloadMedia()
    viewModel.didDisappear()
    expect(App.detecionModule.delegate).to(beNil())
  }

  func testInteractiveScene_reactionBeforeFininsh() {
    scene.mediaNodes = [photo1, photo2]
    scene.edges = [edge1to2, edge1to3]
    initViewModel(with: scene)
    expect(self.viewModel.currentMedia).to(equal(photo1))
    expect(self.viewModelDelegate.displayed).to(equal(photo1))
    viewModel.didDownloadMedia()
    // Expect a view event to be sent
    expect(self.eventCount).toEventually(equal(1))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(edge1to2.reaction!)
    // Wait for reaction event
    expect(self.eventCount).toEventually(equal(2))
    expect(self.lastEvent.eventType).to(equal(EventType.reaction))
    // Should update next media
    expect(self.viewModel.nextMedia).to(equal(photo2))
    // Finishes media
    viewModelDelegate.mediaDidFinish()
    // Should navigate to next media
    expect(self.viewModel.currentMedia).to(equal(photo2))
    expect(self.viewModelDelegate.displayed).to(equal(photo2))
    // Should reset next media
    expect(self.viewModel.nextMedia).to(beNil())
    // Should stop reaction detection
    expect(App.detecionModule.delegate).to(beNil())
    // Triggers didDisplay
    viewModel.didDownloadMedia()
    // Wait for next view event
    expect(self.eventCount).toEventually(equal(3))
    expect(self.lastEvent.eventType).to(equal(EventType.view))
    // Should resume reaction detection
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
  }

  func testInteractiveScene_finishBeforeReaction() {
    scene.mediaNodes = [photo1, photo2]
    scene.edges = [edge1to2]
    initViewModel(with: scene)
    // Finishes media
    viewModel.didDownloadMedia()
    viewModelDelegate.mediaDidFinish()
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(edge1to2.reaction!)
    // Should navigate to next media
    expect(self.viewModel.currentMedia).toEventually(equal(photo2))
    expect(self.viewModelDelegate.displayed).to(equal(photo2))
    expect(self.viewModel.nextMedia).to(beNil())
  }

  func testInteractiveScene_multipleLevels() {
    scene.mediaNodes = [photo1, photo2, photo3]
    scene.edges = [edge1to2, edge2to3]
    initViewModel(with: scene)
    // Finishes media
    viewModel.didDownloadMedia()
    viewModelDelegate.mediaDidFinish()
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(edge1to2.reaction!)
    // Should navigate to next media
    expect(self.viewModel.currentMedia).toEventually(equal(photo2))
    // Finishes media
    viewModel.didDownloadMedia()
    viewModelDelegate.mediaDidFinish()
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(edge2to3.reaction!)
    // Should navigate to next media
    expect(self.viewModel.currentMedia).toEventually(equal(photo3))
  }

  class TestsSceneViewDelegate: SceneViewDelegate {
    var didShow = false
    var displayed: Media?
    var finished = false
    var viewModel: SceneViewModel!
    var animatedImage = false

    func mediaDidFinish() {
      finished = true
      viewModel.didFinish()
    }

    func animateReactionImage() {
      animatedImage = true
    }

    func show(alert: String, withTitle: String, okAction: String) {
      didShow = true
    }

    func display(media: Media) {
      displayed = media
    }

    func mediaFinished() -> Bool {
      return finished
    }

    func hideMedia() {
      displayed = nil
    }
  }
}
