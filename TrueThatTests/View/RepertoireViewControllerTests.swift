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

class RepertoireViewControllerTests : BaseUITests {
  var fetchedReactables: [Reactable] = []
  var viewController: RepertoireViewController!
  
  override func setUp() {
    super.setUp()
    
    stub(condition: isPath(RepertoireApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
      self.fetchedReactables = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "RepertoireScene") as! RepertoireViewController
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }
  
  func assertDisplayed(reactable: Reactable) {
    expect(self.viewController.reactablesPage.currentViewController?.viewModel?.model.id).toEventually(equal(reactable.id))
    expect(self.viewController.reactablesPage.currentViewController?.viewModel?.model.viewed).toEventually(beTrue())
  }
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(reactable: reactable)
  }
  
  func testNavigation() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "repertoire view", in: .down)
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(StudioViewController.self))
  }
  
  func testNavigationWhenReactableDisplayed() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    assertDisplayed(reactable: reactable)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "ReactableView", in: .down)
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(StudioViewController.self))
  }
}
