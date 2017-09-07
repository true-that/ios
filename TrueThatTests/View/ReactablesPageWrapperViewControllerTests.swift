//
//  ReactablesPageWrapperViewControllerTests.swift
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

class ReactablesPageWrapperViewControllerTests : BaseUITests {
  var fetchedReactables: [Reactable] = []
  var viewController: ReactablesPageWrapperViewController!
  
  override func setUp() {
    super.setUp()
    
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
      self.fetchedReactables = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    stub(condition: isPath(InteractionApi.path)) {request -> OHHTTPStubsResponse in
      let requestEvent = InteractionEvent(json: JSON(Data(fromStream: request.httpBodyStream!)))
      let data = try? JSON(from: requestEvent).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "ReactablesPageWrapperScene") as! ReactablesPageWrapperViewController
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    viewController.viewModel.fetchingDelegate = FetchReactablesTestsDelegate()
  }
  
  func assertDisplayed(reactable: Reactable) {
    expect(self.viewController.reactablesPage.currentViewController?.viewModel?.model.id).toEventually(equal(reactable.id))
    expect(self.viewController.reactablesPage.currentViewController?.viewModel?.model.viewed).toEventually(beTrue(), timeout: 10.0)
    if self.viewController.reactablesPage.currentViewController?.viewModel?.model is Short {
      expect((self.viewController.reactablesPage.currentViewController?.mediaViewController as! ShortMediaViewController).player?.currentTime()).toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    }
    // Loading image should be hidden
    expect(self.viewController.loadingImage.isHidden).to(beTrue())
  }
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    viewController.didAuthOk()
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    assertDisplayed(reactable: reactable)
  }
  
  func testEmotionalReaction() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 4],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(reactable: reactable)
    fakeDetectionModule.detect(.happy)
    expect(self.viewController.reactablesPage.currentViewController!.reactionEmojiLabel.text)
      .to(equal(Emotion.happy.emoji))
    expect(self.viewController.reactablesPage.currentViewController!.reactionsCountLabel.text)
      .to(equal("5"))
  }
  
  // Should not fetch reactables before view appeared
  func testNotDisplayBeforePresent() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "The", lastName: "Flinstons", deviceId: "stonePhone"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    // Trigger viewDidDisappear
    UIApplication.shared.keyWindow!.rootViewController = nil
    viewController.didAuthOk()
    expect(self.viewController.reactablesPage.currentViewController == nil).toNotEventually(beFalse())
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
    // Loading image should be shown
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    expect(self.viewController.reactablesPage.currentViewController == nil).toNotEventually(beFalse())
  }
  
  func testMultipleTypes() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Breaking", lastName: "Bad", deviceId: "iphone"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let pose = Pose(id: 2, userReaction: .happy,
                      director: User(id: 1, firstName: "Emma", lastName: "Watson", deviceId: "iphone2"),
                      reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                      viewed: false,
                      imageUrl: "https://storage.googleapis.com/truethat-test-studio/testing/happy-selfie.jpg")
    let short = Short(id: 3, userReaction: .happy,
                      director: User(id: 1, firstName: "Emma", lastName: "Watson", deviceId: "iphone2"),
                      reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                      viewed: false,
                      videoUrl: URL(string: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4"))
    fetchedReactables = [reactable, pose, short]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first reactable
    assertDisplayed(reactable: reactable)
    // Navigate to next reactable
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .right)
    assertDisplayed(reactable: pose)
    // Navigate to next reactable
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .right)
    assertDisplayed(reactable: short)
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
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .right)
    assertDisplayed(reactable: reactable2)
    // Navigate back to previous reactable
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .left)
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
                               created: Date(), viewed: false)
    fetchedReactables = [reactable1]
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    // Should display first reactable
    assertDisplayed(reactable: reactable1)
    // Navigate to next reactable
    fetchedReactables = [reactable2]
    tester().swipeView(withAccessibilityLabel: "reactable view", in: .right)
    // Loading image should not be shown
    expect(self.viewController.loadingImage.isHidden).toNotEventually(beFalse())
    assertDisplayed(reactable: reactable2)
  }
  
  func testReport() {
    let reactable = Pose(id: 2, userReaction: .happy,
                         director: User(id: 1, firstName: "Emma", lastName: "Watson",
                                        deviceId: "iphone2"),
                         reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                         viewed: false,
                         imageUrl: "https://storage.googleapis.com/truethat-test-studio/testing/happy-selfie.jpg")
    fetchedReactables = [reactable]
    // Displays the reactable
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.didAuthOk()
    assertDisplayed(reactable: reactable)
    expect(self.viewController.reactablesPage.currentViewController!.optionsButton.isHidden).toEventually(beFalse())
    // Exposes options menu
    tester().tapView(withAccessibilityLabel: "options")
    expect(self.viewController.reactablesPage.currentViewController!.reportLabel.isHidden).toEventually(beFalse())
    tester().tapView(withAccessibilityLabel: "report")
    expect(self.viewController.reactablesPage.currentViewController!.reportLabel.isHidden).toEventually(beTrue())
    // Should eventually see the reported alert.
    tester().tapView(withAccessibilityLabel: "got it")
  }
  
  class FetchReactablesTestsDelegate: FetchReactablesDelegate {
    func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
      return TheaterApi.fetchReactables(for: App.authModule.current!)
    }
  }
}
