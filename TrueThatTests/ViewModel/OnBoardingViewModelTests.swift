//
//  OnBoardingViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class OnBoardingViewModelTests: BaseTests {
  let fullName = "Jack Sparrow"
  var viewModel: OnBoardingViewModel!
  var viewModelDelegate: OnBoardingTestDelegate!

  override func setUp() {
    super.setUp()
    // Sets up backend for sign ups
    stub(condition: isPath(AuthApi.path)) { request -> OHHTTPStubsResponse in
      let requestUser = User(json: JSON(Data(fromStream: request.httpBodyStream!)))
      requestUser.id = 1
      let data = try? JSON(from: requestUser).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    // Signs out
    App.authModule.signOut()
    // Initializes view model
    viewModel = OnBoardingViewModel()
    viewModelDelegate = OnBoardingTestDelegate(viewModel)
    viewModel.delegate = viewModelDelegate
    App.authModule.delegate = viewModelDelegate
  }

  func assertFinalStage() {
    // Should be listening to reaction detection.
    expect(App.detecionModule.delegate as! OnBoardingViewModel === self.viewModel).to(beTrue())
    // Should show "smile to complete" text
    expect(self.viewModel.completionLabelHidden.value).to(beFalse())
    // Warning should be hidden
    expect(self.viewModel.warningLabelHidden.value).to(beTrue())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    // Show visual indicator of a valid name
    expect(self.viewModel.nameTextFieldBorderColor.value.value).to(equal(Color.success.value))
  }

  func testSuccessfulOnBoarding() {
    // Load view
    viewModel.didAppear()
    // "Type" full name
    viewModel.nameTextField.value = fullName
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone.first!)
    // Should show loading indicator
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    // On boarding is finished successfully
    expect(self.viewModelDelegate.authOk).toEventually(beTrue())
  }

  func testSignUpDidFail() {
    // Sets up an ill backend
    stub(condition: isPath(AuthApi.path)) { _ -> OHHTTPStubsResponse in
      OHHTTPStubsResponse(data: Data(), statusCode: 500,
                          headers: ["Content-Type": "application/json"])
    }
    // Load view
    viewModel.didAppear()
    // "Type" full name
    viewModel.nameTextField.value = fullName
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone.first!)
    // Auth should fail
    expect(self.viewModelDelegate.authFail).toEventually(beTrue())
    // Should show correct warning
    expect(self.viewModel.warningLabelHidden.value).to(beFalse())
    expect(self.viewModel.warningLabelText.value).to(equal(OnBoardingViewModel.signUpFailedText))
    // Should hide loading image
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    // Can try again
    // Sets up proper backend
    stub(condition: isPath(AuthApi.path)) { request -> OHHTTPStubsResponse in
      let requestUser = User(json: JSON(Data(fromStream: request.httpBodyStream!)))
      requestUser.id = 1
      let data = try? JSON(from: requestUser).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone.first!)
    // On boarding is finished successfully
    expect(self.viewModelDelegate.authOk).toEventually(beTrue())
  }

  func testAppearWithValidName() {
    // Already type full name
    viewModel.nameTextField.value = fullName
    // Load view
    viewModel.didAppear()
    // Should enter final on boarding stage
    assertFinalStage()
  }

  func testCancelFinalStage() {
    // Already type full name
    viewModel.nameTextField.value = fullName
    viewModel.didAppear()
    assertFinalStage()
    // Edit name again
    viewModel.delegate.requestNameTextFieldFocus()
    // Should cancel final stage
    expect(App.detecionModule.delegate).to(beNil())
    expect(self.viewModel.completionLabelHidden.value).to(beTrue())
  }

  func testCantHidDoneWithInvalidName() {
    viewModel.nameTextField.value = fullName.components(separatedBy: " ")[0]
    // Should not be able to hit done when only first name is typed.
    expect(self.viewModel.nameFieldDidReturn()).to(beFalse())
  }

  func testTyping() {
    let firstName = StringHelper.extractFirstName(of: fullName)
    let lastName = StringHelper.extractLastName(of: fullName)
    viewModel.didAppear()
    // Type only first name
    viewModel.nameTextField.value = firstName
    // Cant hit done
    expect(self.viewModel.nameFieldDidReturn()).to(beFalse())
    // Visual indicator of illegal name
    expect(self.viewModel.nameTextFieldBorderColor.value.value).to(equal(Color.error.value))
    // Show warning with correct text
    expect(self.viewModel.warningLabelHidden.value).to(beFalse())
    expect(self.viewModel.warningLabelText.value).to(equal(OnBoardingViewModel.invalidNameText))
    // Dont start detection just yet
    expect(App.detecionModule.delegate).to(beNil())
    // Type last name
    viewModel.nameTextField.value += " " + lastName
    // Visual indicator of valid full name
    expect(self.viewModel.nameTextFieldBorderColor.value.value).to(equal(Color.success.value))
    // Hide warning
    expect(self.viewModel.warningLabelHidden.value).to(beTrue())
    // Hit done and move to final stage
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    assertFinalStage()
  }

  class OnBoardingTestDelegate: OnBoardingDelegate, AuthDelegate {
    var authOk = false
    var authFail = false
    var nameTextFieldFocused = false
    weak var viewModel: OnBoardingViewModel!

    init(_ viewModel: OnBoardingViewModel) {
      self.viewModel = viewModel
    }

    func requestNameTextFieldFocus() {
      nameTextFieldFocused = true
      viewModel.nameFieldDidBeginEditing()
    }

    func loseNameTextFieldFocus() {
      nameTextFieldFocused = false
    }

    func didAuthOk() {
      authOk = true
    }

    func didAuthFail() {
      authFail = true
      viewModel.signUpDidFail()
    }
  }
}
