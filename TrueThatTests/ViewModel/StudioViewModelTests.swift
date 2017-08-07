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
    expect(self.viewModelDelegate.previewRestored).to(beTrue())
    self.viewModelDelegate.previewRestored = false
    // Capture & switch camera buttons are exposed
    expect(self.viewModel.captureButtonHidden.value).to(beFalse())
    expect(self.viewModel.switchCameraButtonHidden.value).to(beFalse())
    // Cancel & send buttons are hidden
    expect(self.viewModel.cancelButtonHidden.value).to(beTrue())
    expect(self.viewModel.sendButtonHidden.value).to(beTrue())
    // Should not store directed reactable
    expect(self.viewModel.directed).to(beNil())
  }
  
  func assertAppriving() {
    // Should have approval state
    expect(self.viewModel.state).to(equal(StudioViewModel.State.approving))
    // Should not restore preview
    expect(self.viewModelDelegate.previewRestored).to(beFalse())
    // Capture & switch camera buttons are hidden
    expect(self.viewModel.captureButtonHidden.value).to(beTrue())
    expect(self.viewModel.switchCameraButtonHidden.value).to(beTrue())
    // Cancel & send buttons are exposed
    expect(self.viewModel.cancelButtonHidden.value).to(beFalse())
    expect(self.viewModel.sendButtonHidden.value).to(beFalse())
    // Should have a directed reactable
    expect(self.viewModel.directed).toNot(beNil())
  }
  
  func assertPublished() {
    // Should leave studio
    expect(self.viewModelDelegate.leftStudio).to(beTrue())
  }
  
  func testCapture() {
    viewModel.didAppear()
    assertDirecting()
    viewModel.didCapture(imageData: Data())
    assertAppriving()
  }
  
  func testSend() {
    viewModel.didCapture(imageData: Data())
    assertAppriving()
    viewModel.didSend()
    expect(self.requestCount).toEventually(equal(1))
    assertPublished()
  }
  
  func testResumeDirectingAfterPublish() {
    viewModel.state = StudioViewModel.State.published
    viewModel.didAppear()
    assertDirecting()
  }
  
  class StudioViewModelTestsDelegate : StudioViewModelDelegate {
    var previewRestored = false
    var leftStudio = false
    
    func restorePreview() {
      previewRestored = true
    }
    
    func leaveStudio() {
      leftStudio = true
    }
  }
}
