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

class TheaterViewControllerTests : BaseUITests {
  var fetchedReactables: [Reactable] = []
  var viewController: TheaterViewController!
  
  override func setUp() {
    super.setUp()
    
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
      self.fetchedReactables = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "TheaterScene")
      as! TheaterViewController
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }
  
  func assertDisplayed(reactable: Reactable) {
    expect(self.viewController.reactablesPageWrapper.reactablesPage.currentViewController?
      .viewModel?.model).toEventually(equal(reactable))
  }
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                             deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    reactable.viewed = true
    assertDisplayed(reactable: reactable)
  }

  func testNavigation() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "theater view", in: .up)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
  
  func testNavigationWhenReactableDisplayed() {
    let reactable = Pose(id: 1, userReaction: .sad,
                         director: User(id: 1, firstName: "The", lastName: "Flinstons",
                                        deviceId: "stonePhone"),
                         reactionCounters: [.sad: 1000, .happy: 1234], created: Date(),
                         viewed: false,
                         imageUrl: "https://www.bbcgoodfood.com/sites/default/files/styles/carousel_medium/public/chicken-main_0.jpg")
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    reactable.viewed = true
    assertDisplayed(reactable: reactable)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .up)
    expect(UITestsHelper.currentViewController)
      .toEventually(beAnInstanceOf(StudioViewController.self))
  }
}
