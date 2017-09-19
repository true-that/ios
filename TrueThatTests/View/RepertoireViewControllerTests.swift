//
//  RepertoireViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 08/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import AVFoundation
import OHHTTPStubs
import SwiftyJSON
import Nimble

class RepertoireViewControllerTests: BaseUITests {
  var fetchedScenes: [Scene] = []
  var viewController: RepertoireViewController!
  var scene: Scene!

  override func setUp() {
    super.setUp()

    PhotoViewController.finishTimeoutSeconds = 0.1

    stub(condition: isPath(RepertoireApi.path)) { _ -> OHHTTPStubsResponse in
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
    viewController = storyboard.instantiateViewController(withIdentifier: "RepertoireScene")
      as! RepertoireViewController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())

    scene = Scene(id: 1, director: App.authModule.current,
                  reactionCounters: [.disgust: 1000, .happy: 1234],
                  created: Date(),
                  mediaNodes: [Photo(id: 1, url: "https://img-ovh-cloud.zszywka.pl/0/0563/7131-piekna-kalisi-.jpg")],
                  edges: nil)
  }

  func assertDisplayed(scene: Scene) {
    App.log.debug("assertDisplayed")
    expect(self.viewController.scenesPageWrapper.scenesPage.currentViewController?.viewModel).toEventuallyNot(beNil())
    let viewModel = viewController.scenesPageWrapper.scenesPage.currentViewController!.viewModel!
    expect(viewModel.scene.id).toEventually(equal(scene.id))
    expect(viewModel.currentMedia).toEventuallyNot(beNil())
    expect(viewModel.mediaViewed[viewModel.currentMedia!]).toEventually(beTrue(), timeout: 5.0)
    if viewModel.currentMedia is Video {
      expect((self.viewController.scenesPageWrapper.scenesPage.currentViewController?.mediaViewController
        as! VideoViewController).player?.currentTime())
        .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    }
  }

  func testDisplayScene() {
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene)
  }

  func testNavigation() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "repertoire view", in: .down)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }

  func testNavigationWhenPhotoDisplayed() {
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "photo", in: .down)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
  
  func testNavigationWhenVideoDisplayed() {
    fetchedScenes = [Scene(id: 1, director: App.authModule.current,
                           reactionCounters: [.disgust: 1000, .happy: 1234],
                           created: Date(),
                           mediaNodes: [Video(id: 1, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4")],
                           edges: nil)]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(scene: scene)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "video", in: .down)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
}
