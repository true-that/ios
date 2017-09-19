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

    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "StudioScene")
      as! StudioViewController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    viewController.captureButton.delegate = SwiftyCamButtonTestDelegate(viewModel: viewController.viewModel)
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
    viewController.beginAppearanceTransition(true, animated: false)
    assertCamera()
    tester().tapView(withAccessibilityLabel: "capture")
    assertEdit()
  }

  func testRecordVideo() {
    viewController.beginAppearanceTransition(true, animated: false)
    assertCamera()
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    assertEdit()
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }

  func testCancel() {
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "capture")
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertCamera()
  }

  func testCancelVideo() {
    viewController.beginAppearanceTransition(true, animated: false)
    tester().longPressView(withAccessibilityLabel: "capture", duration: 1.0)
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertCamera()
  }

  func testSend() {
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "capture")
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }

  func testFailedSend() {
    // Set up an ill server
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      self.requestSent = true
      usleep(1_000_000)
      return OHHTTPStubsResponse(data: Data(), statusCode: 500,
                                 headers: ["Content-Type": "application/json"])
    }
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "capture")
    tester().tapView(withAccessibilityLabel: "send")
    assertWillSend()
    // Tap the failure dialogue
    tester().tapView(withAccessibilityLabel: StudioViewModel.saveFailedOkText)
    assertEdit()
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

  func testSendInteractiveFlow() {
    // Take a picture
    tester().tapView(withAccessibilityLabel: "capture")
    // Should proceed to edit state
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "surprise reaction")
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
    // Redo the surprise ending
    tester().tapView(withAccessibilityLabel: "previous media")
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "surprise reaction")
    assertEdit()
    tester().tapView(withAccessibilityLabel: "cancel")
    assertEdit()
    // Chose a reaction
    tester().tapView(withAccessibilityLabel: "surprise reaction")
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
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
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
