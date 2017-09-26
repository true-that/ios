//
//  StudioViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class StudioViewModelTests: BaseTests {
  var viewModel: StudioViewModel!
  var viewModelDelegate: StudioViewModelTestsDelegate!
  var requestCount = 0

  override func setUp() {
    super.setUp()
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(from: Scene(
        id: 1, director: nil, reactionCounters: nil, created: nil, mediaNodes: nil, edges: nil))
        .rawData()
      self.requestCount += 1
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    requestCount = 0
    viewModel = StudioViewModel()
    viewModelDelegate = StudioViewModelTestsDelegate()
    viewModel.delegate = viewModelDelegate
  }

  func assertCamera() {
    // Should have camera state
    expect(self.viewModel.state).to(equal(StudioViewModel.State.camera))
    // Should restore preview
    expect(self.viewModel.cameraSessionHidden.value).to(beFalse())
    // Capture & switch camera buttons are exposed
    expect(self.viewModel.captureButtonHidden.value).to(beFalse())
    expect(self.viewModel.switchCameraButtonHidden.value).to(beFalse())
    // Capture button has capture image
    expect(self.viewModel.captureButtonImageName.value).to(equal(StudioViewModel.captureImageName))
    // Cancel & send buttons are hidden
    expect(self.viewModel.cancelButtonHidden.value).to(beTrue())
    expect(self.viewModel.sendButtonHidden.value).to(beTrue())
    // Should hide directed scene
    expect(self.viewModel.scenePreviewHidden.value).to(beTrue())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    // Chosen reaction should null when directed scene is null
    if viewModel.directed != nil {
      expect(self.viewModel.chosenReaction).toNot(beNil())
    }
    // Displayed media should be nil
    expect(self.viewModelDelegate.displayed).to(beNil())
  }

  func assertEdit() {
    // Should have approval state
    expect(self.viewModel.state).to(equal(StudioViewModel.State.edit))
    // Should not restore preview
    expect(self.viewModel.cameraSessionHidden.value).to(beTrue())
    // Capture & switch camera buttons are hidden
    expect(self.viewModel.captureButtonHidden.value).to(beTrue())
    expect(self.viewModel.switchCameraButtonHidden.value).to(beTrue())
    // Cancel & send buttons are exposed
    expect(self.viewModel.cancelButtonHidden.value).to(beFalse())
    expect(self.viewModel.sendButtonHidden.value).to(beFalse())
    // Should have a directed scene
    expect(self.viewModel.directed).toNot(beNil())
    expect(self.viewModelDelegate.displayed).to(equal(self.viewModel.currentMedia!))
    // Should show directed scene
    expect(self.viewModel.scenePreviewHidden.value).to(beFalse())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }

  func assertSending() {
    // Loading image should be shown
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    let current = requestCount
    expect(self.requestCount).toEventually(equal(current + 1))
  }

  func assertPublished() {
    // Should leave studio
    expect(self.viewModelDelegate.leftStudio).to(beTrue())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }

  func testCaptureImage() throws {
    viewModel.didAppear()
    assertCamera()
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertEdit()
  }

  func testRecordVideo() throws {
    viewModel.didAppear()
    assertCamera()
    viewModel.didStartRecordingVideo()
    // Capture button has recird video image
    expect(self.viewModel.captureButtonImageName.value)
      .to(equal(StudioViewModel.recordVideoImageName))
    viewModel.didFinishRecordingVideo()
    expect(self.viewModel.captureButtonImageName.value).to(equal(StudioViewModel.captureImageName))
    try viewModel.didFinishProcessVideo(url: URL(
      dataRepresentation: Data(contentsOf:
        URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/wink.mp4",
            relativeTo: BaseTests.baseDir)),
      relativeTo: nil)!)
    assertEdit()
    // Sending video
    viewModel.willSend()
    assertSending()
    assertPublished()
  }

  func testSend() throws {
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertEdit()
    viewModel.willSend()
    assertSending()
    assertPublished()
  }

  func testSendDidFail() throws {
    // Set up an ill server
    stub(condition: isPath(StudioApi.path)) { _ -> OHHTTPStubsResponse in
      self.requestCount += 1
      return OHHTTPStubsResponse(data: Data(), statusCode: 500,
                                 headers: ["Content-Type": "application/json"])
    }
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertEdit()
    viewModel.willSend()
    assertSending()
    expect(self.viewModelDelegate.alertDidShow).to(beTrue())
    assertEdit()
  }

  func testResumeDirectingAfterPublish() {
    viewModel.state = StudioViewModel.State.published
    viewModel.didAppear()
    assertCamera()
  }

  func testBasicInteractiveScene() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    // Chose a follow up reaction
    viewModel.didChose(reaction: .disgust)
    assertCamera()
    viewModel.didCapture(imageData: "2".data(using: .utf8)!)
    assertEdit()
    // Should show previous button
    expect(self.viewModel.previousMediaHidden.value).to(beFalse())
    // Expect a flow tree with two nodes
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(2))
    let scene = viewModel.directed!
    expect(scene.next(of: scene.rootMedia!, on: .disgust)).toNot(beNil())
    // Send the scene
    viewModel.willSend()
    assertSending()
  }

  func testDeepInteractiveScene() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    // Chose a follow up reaction
    viewModel.didChose(reaction: .disgust)
    assertCamera()
    viewModel.didCapture(imageData: "2".data(using: .utf8)!)
    assertEdit()
    // Chose a follow up reaction
    viewModel.didChose(reaction: .happy)
    assertCamera()
    viewModel.didCapture(imageData: "3".data(using: .utf8)!)
    assertEdit()
    // Go to root media
    viewModel.displayingParentMedia()
    viewModel.displayingParentMedia()
    expect(self.viewModel.currentMedia).to(equal(viewModel.directed!.rootMedia!))
    // Chose a different follow up reaction
    viewModel.didChose(reaction: .fear)
    assertCamera()
    viewModel.didCapture(imageData: "4".data(using: .utf8)!)
    assertEdit()
    // Return to root media and chose first reaction
    viewModel.displayingParentMedia()
    viewModel.didChose(reaction: .disgust)
    assertEdit()
    // Chose a new reaction
    viewModel.didChose(reaction: .surprise)
    assertCamera()
    viewModel.didCapture(imageData: "5".data(using: .utf8)!)
    // Verify flow tree
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(5))
    let scene = viewModel.directed!
    expect(scene.next(of: scene.next(of: scene.rootMedia!, on: .disgust)!, on: .happy)).toNot(beNil())
    expect(scene.next(of: scene.next(of: scene.rootMedia!, on: .disgust)!, on: .surprise)).toNot(beNil())
    expect(scene.next(of: scene.rootMedia!, on: .fear)).toNot(beNil())
  }

  func testPreviousMedia() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    // Chose a follow up reaction
    viewModel.didChose(reaction: .disgust)
    assertCamera()
    viewModel.didCapture(imageData: "2".data(using: .utf8)!)
    assertEdit()
    // Go to root media
    viewModel.displayingParentMedia()
    // Should edit root media
    assertEdit()
    expect(self.viewModel.currentMedia).to(equal(viewModel.directed!.rootMedia!))
  }

  func testPreviousMediaHiddenFromRootMedia() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    expect(self.viewModel.previousMediaHidden.value).to(beTrue())
  }

  func testCancelNestedMedia() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(1))
    // Chose a follow up reaction
    viewModel.didChose(reaction: .disgust)
    assertCamera()
    viewModel.didCapture(imageData: "2".data(using: .utf8)!)
    assertEdit()
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(2))
    // Chose a nested follow up reaction
    viewModel.didChose(reaction: .happy)
    assertCamera()
    viewModel.didCapture(imageData: "3".data(using: .utf8)!)
    assertEdit()
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(3))
    // Cancel last media
    viewModel.didCancel()
    assertEdit()
    // Should have two nodes
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(2))
  }

  func testCancelRootMedia() {
    viewModel.didCapture(imageData: "1".data(using: .utf8)!)
    assertEdit()
    // Chose a follow up reaction
    viewModel.didChose(reaction: .disgust)
    assertCamera()
    viewModel.didCapture(imageData: "2".data(using: .utf8)!)
    assertEdit()
    // Chose a nested follow up reaction
    viewModel.didChose(reaction: .happy)
    assertCamera()
    viewModel.didCapture(imageData: "3".data(using: .utf8)!)
    assertEdit()
    expect(self.viewModel.directed?.mediaNodes?.count).to(equal(3))
    // Go to root media
    viewModel.displayingParentMedia()
    viewModel.displayingParentMedia()
    expect(self.viewModel.currentMedia).to(equal(viewModel.directed!.rootMedia!))
    // Cancel root media
    viewModel.didCancel()
    assertCamera()
    // Should have a null scene
    expect(self.viewModel.directed).to(beNil())
  }

  class StudioViewModelTestsDelegate: StudioViewModelDelegate {

    var leftStudio = false
    var sent = false
    var displayed: Media?
    var alertDidShow = false

    func leaveStudio() {
      leftStudio = true
    }

    func hideMedia() {
      displayed = nil
    }

    func display(media: Media) {
      displayed = media
    }

    func didSend() {
      sent = true
    }

    func show(alert: String, withTitle: String, okAction: String) {
      alertDidShow = true
    }
  }
}
