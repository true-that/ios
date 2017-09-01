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
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(from: Reactable(
        id: 1, userReaction: nil, director: nil, reactionCounters: nil, created: nil, viewed: nil))
        .rawData()
      self.requestCount += 1
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    requestCount = 0
    viewModel = StudioViewModel()
    viewModelDelegate = StudioViewModelTestsDelegate()
    viewModel.delegate = viewModelDelegate
  }
  
  func assertDirecting() {
    // Should have directing state
    expect(self.viewModel.state).to(equal(StudioViewModel.State.directing))
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
    // Should not store directed reactable
    expect(self.viewModel.directed).to(beNil())
    expect(self.viewModelDelegate.displayed).to(beNil())
    // Should hide directed reactable
    expect(self.viewModel.reactablePreviewHidden.value).to(beTrue())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }
  
  func assertApproving() {
    // Should have approval state
    expect(self.viewModel.state).to(equal(StudioViewModel.State.approving))
    // Should not restore preview
    expect(self.viewModel.cameraSessionHidden.value).to(beTrue())
    // Capture & switch camera buttons are hidden
    expect(self.viewModel.captureButtonHidden.value).to(beTrue())
    expect(self.viewModel.switchCameraButtonHidden.value).to(beTrue())
    // Cancel & send buttons are exposed
    expect(self.viewModel.cancelButtonHidden.value).to(beFalse())
    expect(self.viewModel.sendButtonHidden.value).to(beFalse())
    // Should have a directed reactable
    expect(self.viewModel.directed).toNot(beNil())
    expect(self.viewModelDelegate.displayed).to(equal(self.viewModel.directed))
    // Should show directed reactable
    expect(self.viewModel.reactablePreviewHidden.value).to(beFalse())
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
    assertDirecting()
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertApproving()
  }
  
  func testRecordVideo()  throws {
    viewModel.didAppear()
    assertDirecting()
    viewModel.didStartRecordingVideo()
    // Capture button has recird video image
    expect(self.viewModel.captureButtonImageName.value).to(equal(StudioViewModel.recordVideoImageName))
    viewModel.didFinishRecordingVideo()
    expect(self.viewModel.captureButtonImageName.value).to(equal(StudioViewModel.captureImageName))
    try viewModel.didFinishProcessVideo(url: URL(
      dataRepresentation: Data(contentsOf:
        URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/wink.mp4", relativeTo:BaseTests.baseDir)),
      relativeTo: nil)!)
    assertApproving()
    // Sending video
    viewModel.willSend()
    assertSending()
    assertPublished()
  }
  
  func testSend() throws {
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertApproving()
    viewModel.willSend()
    assertSending()
    assertPublished()
  }
  
  func testSendDidFail() throws {
    // Set up an ill server
    stub(condition: isPath(StudioApi.path)) {request -> OHHTTPStubsResponse in
      self.requestCount += 1
      return OHHTTPStubsResponse(data: Data(), statusCode: 500,
                                 headers: ["Content-Type":"application/json"])
    }
    try viewModel.didCapture(imageData:
      Data(contentsOf: URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/happy_selfie.jpg",
                           relativeTo: BaseTests.baseDir)))
    assertApproving()
    viewModel.willSend()
    assertSending()
    expect(self.viewModelDelegate.alertDidShow).to(beTrue())
    assertApproving()
  }
  
  func testResumeDirectingAfterPublish() {
    viewModel.state = StudioViewModel.State.published
    viewModel.didAppear()
    assertDirecting()
  }
  
  class StudioViewModelTestsDelegate : StudioViewModelDelegate {
    var leftStudio = false
    var sent = false
    var displayed: Reactable?
    var alertDidShow = false
    
    func leaveStudio() {
      leftStudio = true
    }
    
    func displayPreview(of reactable: Reactable?) {
      displayed = reactable
    }
    
    func didSend() {
      sent = true
    }
    
    func show(alert: String, withTitle: String, okAction: String) {
      alertDidShow = true
    }
  }
}
