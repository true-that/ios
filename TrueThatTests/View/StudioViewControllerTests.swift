//
//  StudioViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import Nimble
import OHHTTPStubs
import SwiftyJSON

class StudioViewControllerTests : BaseUITests {
  var viewController: StudioViewController!
  
  override func setUp() {
    super.setUp()
    
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "StudioScene")
      as! StudioViewController
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    viewController.captureButton.delegate = SwiftyCamButtonTestDelegate(viewModel: viewController.viewModel)
  }
  
  func assertDirecting() {
    expect(self.viewController.captureButton.isHidden).to(beFalse())
    expect(self.viewController.reactablePreview.isHidden).to(beTrue())
    expect(self.viewController.switchCameraButton.isHidden).to(beFalse())
    expect(self.viewController.cancelButton.isHidden).to(beTrue())
    expect(self.viewController.sendButton.isHidden).to(beTrue())
    expect(self.viewController.viewModel.state).to(equal(StudioViewModel.State.directing))
    // TODO(ohad): assert camrea preview is live
  }
  
  func assertApproving() {
    expect(self.viewController.captureButton.isHidden).to(beTrue())
    expect(self.viewController.switchCameraButton.isHidden).to(beTrue())
    expect(self.viewController.cancelButton.isHidden).to(beFalse())
    expect(self.viewController.sendButton.isHidden).to(beFalse())
    expect(self.viewController.viewModel.state).to(equal(StudioViewModel.State.approving))
    expect(self.viewController.reactablePreview.isHidden).to(beFalse())
    // TODO(ohad): assert camrea preview is frozen
  }
  
  func testCapturePhoto() {
    viewController.beginAppearanceTransition(true, animated: false)
    assertDirecting()
    tester().tapView(withAccessibilityLabel: "capture photo")
    assertApproving()
  }
  
  func testCancel() {
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "capture photo")
    tester().tapView(withAccessibilityLabel: "cancel")
    assertDirecting()
  }
  
  func testApprove() {
    // Set up mock backend
    var requestSent = false
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(from: Reactable(
        id: 1, userReaction: nil, director: nil, reactionCounters: nil, created: nil, viewed: nil))
        .rawData()
      requestSent = true
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "capture photo")
    tester().tapView(withAccessibilityLabel: "send")
    expect(requestSent).toEventually(beTrue())
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }
  
  func testNavigationToTheater() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "studio view", in: .down)
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(TheaterViewController.self))
  }
  
  func testNavigationToRepertoire() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Swipe up
    tester().swipeView(withAccessibilityLabel: "studio view", in: .up)
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(RepertoireViewController.self))
  }
  
  class SwiftyCamButtonTestDelegate: SwiftyCamButtonDelegate {
    var viewModel: StudioViewModel!
    init(viewModel: StudioViewModel) {
      self.viewModel = viewModel
    }
    
    func buttonWasTapped() {
      viewModel.didCapture(imageData: Data())
    }
    
    func buttonDidBeginLongPress() {}
    
    func buttonDidEndLongPress() {}
    
    func longPressDidReachMaximumDuration() {}
    
    func setMaxiumVideoDuration() -> Double { return 0.0 }
  }
}
