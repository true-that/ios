//
//  ScenesPageWrapperViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 30/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import AVFoundation
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble

class ScenesPageWrapperViewControllerTests: BaseUITests {
  var fetchedScenes: [Scene] = []
  var viewController: ScenesPageWrapperViewController!

  override func setUp() {
    super.setUp()

    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedScenes.map { JSON(from: $0) }).rawData()
      self.fetchedScenes = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    stub(condition: isPath(InteractionApi.path)) { request -> OHHTTPStubsResponse in
      let requestEvent = InteractionEvent(json: JSON(Data(fromStream: request.httpBodyStream!)))
      let data = try? JSON(from: requestEvent).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(
      withIdentifier: "ScenesPageWrapperScene") as! ScenesPageWrapperViewController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    viewController.viewModel.fetchingDelegate = FetchScenesTestsDelegate()
  }

  func assertDisplayed(scene: Scene) {
    expect(self.viewController.scenesPage.currentViewController?.viewModel?.model.id)
      .toEventually(equal(scene.id))
    expect(self.viewController.scenesPage.currentViewController?.viewModel?.model.viewed)
      .toEventually(beTrue(), timeout: 10.0)
    if self.viewController.scenesPage.currentViewController?.viewModel?.model.rootMedia is Video {
      expect((self.viewController.scenesPage.currentViewController?.mediaViewController
          as! VideoViewController).player?.currentTime())
        .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    }
    // Loading image should be hidden
    expect(self.viewController.loadingImage.isHidden).to(beTrue())
  }

  func testDisplayScene() {
    let scene = Scene(id: 1, userReaction: .sad,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.sad: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    viewController.didAuthOk()
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    assertDisplayed(scene: scene)
  }

  func testEmotionalReaction() {
    let scene = Scene(id: 1, userReaction: nil,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.sad: 4],
                      created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene)
    fakeDetectionModule.detect(.happy)
    expect(self.viewController.scenesPage.currentViewController!.reactionEmojiLabel.text)
      .to(equal(Emotion.happy.emoji))
    expect(self.viewController.scenesPage.currentViewController!.reactionsCountLabel.text)
      .to(equal("5"))
  }

  // Should not fetch scenes before view appeared
  func testNotDisplayBeforePresent() {
    let scene = Scene(id: 1, userReaction: .sad,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.sad: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene]
    // Trigger viewDidDisappear
    UIApplication.shared.keyWindow!.rootViewController = nil
    viewController.didAuthOk()
    expect(self.viewController.scenesPage.currentViewController == nil).toNotEventually(beFalse())
  }

  // Should not fetch scenes before user is authenticated
  func testNotDisplayBeforeAuthOk() {
    let scene = Scene(id: 1, userReaction: .sad,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.sad: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    App.authModule.signOut()
    viewController.beginAppearanceTransition(true, animated: false)
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    expect(self.viewController.scenesPage.currentViewController == nil).toNotEventually(beFalse())
  }

  func testMultipleTypes() {
    let scene = Scene(id: 1, userReaction: .sad,
                      director: User(id: 1, firstName: "Breaking", lastName: "Bad",
                                     deviceId: "iphone"),
                      reactionCounters: [.sad: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    let photo = Scene(id: 2, userReaction: .happy,
                      director: User(id: 1, firstName: "Emma", lastName: "Watson",
                                     deviceId: "iphone2"),
                      reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                      viewed: false,
                      media: Photo(url: "https://storage.googleapis.com/truethat-test-studio/testing/happy-selfie.jpg"))
    let video = Scene(id: 3, userReaction: .happy,
                      director: User(id: 1, firstName: "Harry", lastName: "Potter",
                                     deviceId: "iphone2"),
                      reactionCounters: [.happy: 7, .sad: 34], created: Date(),
                      viewed: false,
                      media: Video(url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4"))
    fetchedScenes = [scene, photo, video]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first scene
    assertDisplayed(scene: scene)
    // Navigate to next scene
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    assertDisplayed(scene: photo)
    // Navigate to next scene
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    assertDisplayed(scene: video)
  }

  func testScenesNavigation() {
    let scene1 = Scene(id: 1, userReaction: .sad,
                       director: User(id: 1, firstName: "Breaking", lastName: "Bad",
                                      deviceId: "iphone"),
                       reactionCounters: [.sad: 1000, .happy: 1234],
                       created: Date(), viewed: false, media: nil)
    let scene2 = Scene(id: 2, userReaction: .happy,
                       director: User(id: 1, firstName: "Mr", lastName: "White",
                                      deviceId: "iphone2"),
                       reactionCounters: [.sad: 5000, .happy: 34],
                       created: Date(), viewed: true, media: nil)
    fetchedScenes = [scene1, scene2]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first scene
    assertDisplayed(scene: scene1)
    // Navigate to next scene
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    assertDisplayed(scene: scene2)
    // Navigate back to previous scene
    tester().swipeView(withAccessibilityLabel: "scene view", in: .left)
    assertDisplayed(scene: scene1)
  }

  func testFetchNewScenes() {
    let scene1 = Scene(id: 1, userReaction: .sad,
                       director: User(id: 1, firstName: "Breaking", lastName: "Bad",
                                      deviceId: "iphone"),
                       reactionCounters: [.sad: 1000, .happy: 1234],
                       created: Date(), viewed: false, media: nil)
    let scene2 = Scene(id: 2, userReaction: .happy,
                       director: User(id: 1, firstName: "Mr", lastName: "White",
                                      deviceId: "iphone2"),
                       reactionCounters: [.sad: 5000, .happy: 34],
                       created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene1]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first scene
    assertDisplayed(scene: scene1)
    // Navigate to next scene
    fetchedScenes = [scene2]
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    // Loading image should not be shown
    expect(self.viewController.loadingImage.isHidden).toNotEventually(beFalse())
    assertDisplayed(scene: scene2)
  }

  func testReport() {
    let scene = Scene(id: 2, userReaction: .happy,
                      director: User(id: 1, firstName: "Emma", lastName: "Watson",
                                     deviceId: "iphone2"),
                      reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                      viewed: false,
                      media: Photo(url: "https://storage.googleapis.com/truethat-test-studio/testing/happy-selfie.jpg"))
    fetchedScenes = [scene]
    // Displays the scene
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene)
    expect(self.viewController.scenesPage.currentViewController!.optionsButton.isHidden)
      .toEventually(beFalse())
    // Exposes options menu
    tester().tapView(withAccessibilityLabel: "options")
    expect(self.viewController.scenesPage.currentViewController!.reportLabel.isHidden)
      .toEventually(beFalse())
    tester().tapView(withAccessibilityLabel: "report")
    expect(self.viewController.scenesPage.currentViewController!.reportLabel.isHidden)
      .toEventually(beTrue())
    // Should eventually see the reported alert.
    tester().tapView(withAccessibilityLabel: "got it")
  }

  class FetchScenesTestsDelegate: FetchScenesDelegate {
    func fetchingProducer() -> SignalProducer<[Scene], NSError> {
      return TheaterApi.fetchScenes(for: App.authModule.current!)
    }
  }
}
