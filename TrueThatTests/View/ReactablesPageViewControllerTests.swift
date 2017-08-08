//
//  ReactablesPageViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 30/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble

class ReactablesPageViewControllerTests : BaseUITests {
  var fetchedReactables: [Reactable] = []
  var viewController: ReactablesPageViewController!
  
  override func setUp() {
    super.setUp()
    
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
      self.fetchedReactables = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "ReactablesPageScene") as! ReactablesPageViewController
    viewController.fetchingDelegate = FetchReactablesTestsDelegate()
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }
  
  func assertDisplayed(reactable: Reactable) {
    expect(self.viewController.currentViewController?.viewModel?.model).toEventually(equal(reactable))
    switch reactable {
    case is Scene:
      expect(self.viewController.currentViewController!.viewModel)
        .to(beAnInstanceOf(SceneViewModel.self))
    default:
      expect(self.viewController.currentViewController!.viewModel)
        .to(beAnInstanceOf(ReactableViewModel.self))
    }
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
  
  // Should not fetch reactables before view appeared
  func testNotDisplayBeforePresent() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    UIApplication.shared.keyWindow!.rootViewController = nil
    viewController.didAuthOk()
    expect(self.viewController.currentViewController == nil).toNotEventually(beFalse())
  }
  
  // Should not fetch reactables before user is authenticated
  func testNotDisplayBeforeAuthOk() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    App.authModule.signOut()
    viewController.beginAppearanceTransition(true, animated: false)
    expect(self.viewController.currentViewController == nil).toNotEventually(beFalse())
  }
  
  func testMultipleTypes() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Breaking", lastName: "Bad", deviceId: "iphone"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let scene = Scene(id: 2, userReaction: .happy,
                      director: User(id: 1, firstName: "Mr", lastName: "White", deviceId: "iphone2"),
                      reactionCounters: [.sad: 5000, .happy: 34], created: Date(),
                      viewed: true,
                      imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/A_white_irish_goat.jpg/220px-A_white_irish_goat.jpg")
    fetchedReactables = [reactable, scene]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first reactable
    assertDisplayed(reactable: reactable)
    // Navigate to next reactable
    tester().swipeView(withAccessibilityLabel: "ReactableView", in: .right)
    assertDisplayed(reactable: scene)
  }
  
  func testReactablesNavigation() {
    let reactable1 = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Breaking", lastName: "Bad", deviceId: "iphone"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let reactable2 = Reactable(id: 2, userReaction: .happy,
                               director: User(id: 1, firstName: "Mr", lastName: "White", deviceId: "iphone2"),
                               reactionCounters: [.sad: 5000, .happy: 34],
                               created: Date(), viewed: true)
    fetchedReactables = [reactable1, reactable2]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first reactable
    assertDisplayed(reactable: reactable1)
    // Navigate to next reactable
    tester().swipeView(withAccessibilityLabel: "ReactableView", in: .right)
    assertDisplayed(reactable: reactable2)
    // Navigate back to previous reactable
    tester().swipeView(withAccessibilityLabel: "ReactableView", in: .left)
    assertDisplayed(reactable: reactable1)
  }
  
  func testFetchNewReactables() {
    let reactable1 = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Breaking", lastName: "Bad", deviceId: "iphone"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let reactable2 = Reactable(id: 2, userReaction: .happy,
                               director: User(id: 1, firstName: "Mr", lastName: "White", deviceId: "iphone2"),
                               reactionCounters: [.sad: 5000, .happy: 34],
                               created: Date(), viewed: true)
    fetchedReactables = [reactable1]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first reactable
    assertDisplayed(reactable: reactable1)
    // Navigate to next reactable
    fetchedReactables = [reactable2]
    tester().swipeView(withAccessibilityLabel: "ReactableView", in: .right)
    assertDisplayed(reactable: reactable2)
  }
  
  class FetchReactablesTestsDelegate: FetchReactablesDelegate {
    func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
      return TheaterApi.fetchReactables(for: App.authModule.current!)
    }
  }
}
