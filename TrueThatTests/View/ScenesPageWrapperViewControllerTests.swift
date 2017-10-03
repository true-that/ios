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
  var scene: Scene!

  override func setUp() {
    super.setUp()

    // Hasten media finish.
    PhotoViewController.finishTimeoutSeconds = 0.1

    scene = Scene(id: 1, director: User(id: 1, firstName: "Mr", lastName: "Bean", deviceId: "iphone1"),
                  reactionCounters: [.disgust: 1, .happy: 3], created: Date(),
                  mediaNodes: [Photo(id: 1, url: "https://i.ytimg.com/vi/XrBTDbxOZE8/maxresdefault.jpg")], edges: nil)

    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedScenes.map { JSON(from: $0) }).rawData()
      self.fetchedScenes = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
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

  func assertDisplayed(scene: Scene, mediaId: Int64) {
    expect(self.viewController.scenesPage.currentViewController?.viewModel).toEventuallyNot(beNil())
    let viewModel = viewController.scenesPage.currentViewController!.viewModel!
    expect(viewModel.scene.id).toEventually(equal(scene.id))
    expect(viewModel.currentMedia?.id).toEventually(equal(mediaId))
    expect(viewModel.mediaViewed[viewModel.currentMedia!]).toEventually(beTrue(), timeout: 10.0)
    if viewModel.currentMedia is Video {
      expect((self.viewController.scenesPage.currentViewController?.mediaViewController
          as! VideoViewController).player?.currentTime())
        .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    }
    // Loading image should be hidden
    expect(self.viewController.loadingImage.isHidden).to(beTrue())
  }

  func testDisplayScene() {
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    viewController.didAuthOk()
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    assertDisplayed(scene: scene, mediaId: scene.mediaNodes![0].id!)
  }

  func testEmotionalReaction() {
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene, mediaId: scene.mediaNodes![0].id!)
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(.happy)
    expect(self.viewController.scenesPage.currentViewController!.reactionEmojiLabel.text)
      .to(equal(Emotion.happy.emoji))
    expect(self.viewController.scenesPage.currentViewController!.reactionsCountLabel.text)
      .to(equal("5"))
  }

  // Should not fetch scenes before view appeared
  func testNotDisplayBeforePresent() {
    fetchedScenes = [scene]
    // Trigger viewDidDisappear
    UIApplication.shared.keyWindow!.rootViewController = nil
    viewController.didAuthOk()
    expect(self.viewController.scenesPage.currentViewController == nil).toNotEventually(beFalse())
  }

  // Should not fetch scenes before user is authenticated
  func testNotDisplayBeforeAuthOk() {
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    App.authModule.signOut()
    viewController.beginAppearanceTransition(true, animated: false)
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    expect(self.viewController.scenesPage.currentViewController == nil).toNotEventually(beFalse())
  }

  func testMultipleTypes() {
    let video = Scene(id: 3, director: User(id: 1, firstName: "Harry", lastName: "Potter", deviceId: "iphone2"),
                      reactionCounters: [.happy: 7, .disgust: 34], created: Date(),
                      mediaNodes: [Video(id: 0, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4")], edges: nil)
    fetchedScenes = [scene, video]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene, mediaId: scene.mediaNodes![0].id!)
    // Navigate to next scene
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    assertDisplayed(scene: video, mediaId: video.mediaNodes![0].id!)
  }

  func testInteractiveScene() {
    scene.mediaNodes = [Video(id: 1, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4"), Photo(id: 0, url: "https://i.ytimg.com/vi/XrBTDbxOZE8/maxresdefault.jpg")]
    scene.edges = [Edge(sourceId: 0, targetId: 1, reaction: .happy)]
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first scene
    assertDisplayed(scene: scene, mediaId: 0)
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect reaction
    fakeDetectionModule.detect(scene.edges![0].reaction!)
    // Should display next media
    assertDisplayed(scene: scene, mediaId: 1)
  }

  func testFetchNewScenes() {
    let scene2 = Scene(id: 2, director: User(id: 1, firstName: "Mr", lastName: "White", deviceId: "iphone2"),
                       reactionCounters: [.disgust: 5000, .happy: 34], created: Date(),
                       mediaNodes: [Video(id: 0, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4")], edges: nil)
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first scene
    assertDisplayed(scene: scene, mediaId: scene.mediaNodes![0].id!)
    // Navigate to next scene
    fetchedScenes = [scene2]
    tester().swipeView(withAccessibilityLabel: "scene view", in: .right)
    // Loading image should not be shown
    expect(self.viewController.loadingImage.isHidden).toNotEventually(beFalse())
    assertDisplayed(scene: scene2, mediaId: scene2.mediaNodes![0].id!)
  }

  func testReport() {
    fetchedScenes = [scene]
    // Displays the scene
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene, mediaId: scene.mediaNodes![0].id!)
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
