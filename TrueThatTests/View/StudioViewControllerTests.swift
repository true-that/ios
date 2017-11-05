//
//  StudioViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import KIF
@testable import TrueThat
import Nimble
import OHHTTPStubs
import SwiftyJSON

class StudioViewControllerTests: BaseUITests {
  var viewController: StudioViewController!
  var mainTabController: MainTabController!
  var requestSent: Bool!

  override func setUp() {
    super.setUp()

    // Set up mock backend
    requestSent = false
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      self.viewController.viewModel.directed!.id = 1
      let stubData = try! JSON(from: self.viewController.viewModel.directed!).rawData()
      self.requestSent = true
      usleep(1_000_000)
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }

    // if current view is not main one, then create a new main one.
    if !(UITestsHelper.currentViewController! is MainTabController) {
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      mainTabController = storyboard.instantiateViewController(withIdentifier: "MainScene")
        as! MainTabController
      UIApplication.shared.keyWindow!.rootViewController = mainTabController
      // Test and load the View
      expect(self.mainTabController.view).toNot(beNil())
      UITestsHelper.triggeringViewAppearance(mainTabController)
    }

    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(MainTabController.self))
    mainTabController = UITestsHelper.currentViewController as! MainTabController
    mainTabController.selectedIndex = MainTabController.studioIndex
    viewController = mainTabController.selectedViewController as! StudioViewController
    viewController.captureButton.delegate = SwiftyCamButtonTestDelegate(viewModel: viewController.viewModel)
  }

  override func tearDown() {
    super.tearDown()
    if viewController != nil {
      // Little hack to "restart" the view controller
      viewController.beginAppearanceTransition(false, animated: false)
      viewController.endAppearanceTransition()
      viewController.viewModel = nil
      viewController.viewDidLoad()
      UITestsHelper.triggeringViewAppearance(viewController)
    }
  }

  func assertCamera() {
    expect(self.viewController.viewModel.state).toEventually(equal(StudioViewModel.State.camera))
    expect(self.viewController.captureButton.isHidden).to(beFalse())
    expect(self.viewController.switchCameraButton.isHidden).to(beFalse())
    expect(self.viewController.cancelButton.isHidden).to(beTrue())
    expect(self.viewController.sendButton.isHidden).to(beTrue())
    // Testing view model property as swiftyCam view controller is not created on simulator
    expect(self.viewController.viewModel.cameraSessionHidden.value).to(beFalse())
  }

  func assertEdit() {
    expect(self.viewController.viewModel.state).toEventually(equal(StudioViewModel.State.edit))
    expect(self.viewController.captureButton.isHidden).to(beTrue())
    expect(self.viewController.switchCameraButton.isHidden).to(beTrue())
    expect(self.viewController.cancelButton.isHidden).to(beFalse())
    expect(self.viewController.sendButton.isHidden).to(beFalse())
    expect(self.viewController.viewModel.cameraSessionHidden.value).to(beTrue())
    expect(self.viewController.scenePreview?.view.isHidden).to(beFalse())
  }

  func assertWillSend() {
    expect(self.viewController.loadingImage.isHidden).toEventually(beFalse())
    expect(self.requestSent).toEventually(beTrue())
  }

  func testCapturePhoto() {
    assertCamera()
    tester().tapView(withAccessibilityLabel: "capture")
    assertEdit()
  }

  func testRecordVideo() {
    assertCamera()
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    assertEdit()
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    expect(self.mainTabController.selectedIndex).toEventually(equal(MainTabController.theaterIndex))
  }

  func testCancel() {
    tester().tapView(withAccessibilityLabel: "capture")
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertCamera()
  }

  func testCancelVideo() {
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertCamera()
  }

  func testSend() {
    tester().tapView(withAccessibilityLabel: "capture")
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    expect(self.mainTabController.selectedIndex).toEventually(equal(MainTabController.theaterIndex))
  }

  func testFailedSend() {
    // Set up an ill server
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      self.requestSent = true
      usleep(1_000_000)
      return OHHTTPStubsResponse(data: Data(), statusCode: 500,
                                 headers: ["Content-Type": "application/json"])
    }
    tester().tapView(withAccessibilityLabel: "capture")
    assertEdit()
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    // Tap the failure dialogue
    tester().tapView(withAccessibilityLabel: StudioViewModel.saveFailedOkText)
    assertEdit()
  }

  func testSendInteractiveFlow() {
    // Take a picture
    tester().tapView(withAccessibilityLabel: "capture")
    // Should proceed to edit state
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "omg reaction")
    // Should proceed to camera state.
    assertCamera()
    // Record a video
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    // Should proceed to edit state
    assertEdit()
    // Go back to root media to create an alternative
    tester().tapView(withAccessibilityLabel: "previous media")
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "happy reaction")
    // Should proceed to camera state.
    assertCamera()
    // Take a picture
    tester().tapView(withAccessibilityLabel: "capture")
    // Should proceed to edit state
    assertEdit()
    // Redo the omg ending
    tester().tapView(withAccessibilityLabel: "previous media")
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "omg reaction")
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "omg reaction")
    // Should proceed to camera state.
    assertCamera()
    // Record a video
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    // Should proceed to edit state
    assertEdit()
    // Send the scene
    tester().tapView(withAccessibilityLabel: "send")
    // Should proceed to sent state
    assertWillSend()
    // Should proceed to published state
    expect(self.mainTabController.selectedIndex).toEventually(equal(MainTabController.theaterIndex))
  }

  class SwiftyCamButtonTestDelegate: SwiftyCamButtonDelegate {
    var viewModel: StudioViewModel!
    init(viewModel: StudioViewModel) {
      self.viewModel = viewModel
    }

    func buttonWasTapped() {
      do {
        try viewModel.didCapture(imageData:
          Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                               relativeTo: BaseTests.baseDir)))
      } catch {
        App.log.error("could not capture image")
      }
    }

    func buttonDidBeginLongPress() {
      viewModel.didStartRecordingVideo()
    }

    func buttonDidEndLongPress() {
      viewModel.didFinishRecordingVideo()
      do {
        try viewModel.didFinishProcessVideo(url: URL(
          dataRepresentation: Data(contentsOf:
            URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/wink.mp4", relativeTo: BaseTests.baseDir)),
          relativeTo: nil)!)
      } catch {
        App.log.error("failed to process video")
      }
    }

    func longPressDidReachMaximumDuration() {}

    func setMaxiumVideoDuration() -> Double { return 0.0 }
  }
}
