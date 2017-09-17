//
//  RepertoireViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 08/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class RepertoireViewControllerTests: BaseUITests {
  var fetchedScenes: [Scene] = []
  var viewController: RepertoireViewController!

  override func setUp() {
    super.setUp()

    stub(condition: isPath(RepertoireApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedScenes.map { JSON(from: $0) }).rawData()
      self.fetchedScenes = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "RepertoireScene")
      as! RepertoireViewController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }

  func assertDisplayed(scene: Scene) {
    expect(self.viewController.scenesPageWrapper.scenesPage.currentViewController?
      .viewModel?.model.id).toEventually(equal(scene.id))
    expect(self.viewController.scenesPageWrapper.scenesPage.currentViewController?
      .viewModel?.model.viewed).toEventually(beTrue())
  }

  func testDisplayScene() {
    let scene = Scene(id: 1, userReaction: .disgust,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
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

  func testNavigationWhenSceneDisplayed() {
    let scene = Scene(id: 1, userReaction: .disgust,
                      director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                     deviceId: "stonePhone"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), viewed: false, media: nil)
    fetchedScenes = [scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    assertDisplayed(scene: scene)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "scene view", in: .down)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
}
