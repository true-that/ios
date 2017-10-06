//
//  TheaterViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class TheaterViewControllerTests: BaseUITests {
  var fetchedScenes: [Scene] = []
  var viewController: TheaterViewController!
  var eventCount = 0
  let director = User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone", phoneNumber: "+349857345")

  override func setUp() {
    super.setUp()

    stub(condition: isPath(TheaterApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedScenes.map { JSON(from: $0) }).rawData()
      self.fetchedScenes = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    eventCount = 0
    stub(condition: isPath(InteractionApi.path)) { request -> OHHTTPStubsResponse in
      let requestEvent = InteractionEvent(json: JSON(Data(fromStream: request.httpBodyStream!)))
      let data = try? JSON(from: requestEvent).rawData()
      self.eventCount += 1
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "TheaterScene")
      as! TheaterViewController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }

  func assert(displayed scene: Scene) {
    expect(self.viewController.scenesPageWrapper.scenesPage.currentViewController?
      .viewModel?.scene).toEventually(equal(scene))
    expect(self.eventCount).toEventually(equal(1))
  }

  func testDisplayScene() {
    let photo = Scene(id: 1, director: director, reactionCounters: [.disgust: 1000, .happy: 1234], created: Date(),
                      mediaNodes: [Photo(id: 0, url: "https://www.bbcgoodfood.com/sites/default/files/styles/carousel_medium/public/chicken-main_0.jpg")], edges: nil)
    fetchedScenes = [photo]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assert(displayed: photo)
  }

  func testNavigation() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "theater view", in: .up)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }


  // Ignoring test because of KIF bug https://github.com/kif-framework/KIF/issues/601
  func testNavigationWhenSceneDisplayed() {
    let photo = Scene(id: 1, director: director, reactionCounters: [.disgust: 1000, .happy: 1234], created: Date(),
                      mediaNodes: [Photo(id: 0, url: "https://www.bbcgoodfood.com/sites/default/files/styles/carousel_medium/public/chicken-main_0.jpg")], edges: nil)
    let video = Scene(id: 2, director: director, reactionCounters: [.disgust: 1000, .happy: 1234], created: Date(),
                      mediaNodes: [Video(id: 1, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4")], edges: nil)
    fetchedScenes = [video, photo]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    assert(displayed: video)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "video", in: .up)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
}
