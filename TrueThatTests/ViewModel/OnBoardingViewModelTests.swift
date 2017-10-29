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
    OnBoardingViewModel.detectionDelaySeconds = 0.1
  }

  func assertFinalStage() {
    // Text field responders resigned
    expect(self.viewModelDelegate.nameFocused).to(beFalse())
    expect(self.viewModelDelegate.nameFocused).to(beFalse())
    // Should show "smile to complete" text
    expect(self.viewModel.completionLabelHidden.value).to(beFalse())
    // Warning should be hidden
    expect(self.viewModel.warningLabelHidden.value).to(beTrue())
    // Loading image should be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    // Show visual indicator of valid name and number
    expect(self.viewModel.nameTextFieldBorderColor.value.value).to(equal(Color.success.value))
    expect(self.viewModel.numberTextFieldBorderColor.value.value).to(equal(Color.success.value))
    // Detection should not start right away
    expect(App.detecionModule.delegate).to(beNil())
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    expect(App.detecionModule.delegate as! OnBoardingViewModel === self.viewModel).to(beTrue())
  }

  func doingFirstStage() {
    // Already typed full name
    viewModel.nameTextField.value = fullName
    // Already typed a valid number
    viewModelDelegate.shouldValidateNumber = true
    viewModel.numberFieldTextDidChange()
  }

  func testSuccessfulOnBoarding() {
    // Load view
    viewModel.didAppear()
    doingFirstStage()
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone)
    // Should show loading indicator
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    // On boarding is finished successfully
    expect(self.viewModelDelegate.authOk).toEventually(beTrue())
  }

  func testSuccessfulOnBoarding_notMostLikely() {
    // Load view
    viewModel.didAppear()
    doingFirstStage()
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone, mostLikely: false)
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
    doingFirstStage()
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    // Should enter final on boarding stage
    assertFinalStage()
    // Detect a reaction
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone)
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
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone)
    // On boarding is finished successfully
    expect(self.viewModelDelegate.authOk).toEventually(beTrue())
  }

  func testAppearWithValidName() {
    doingFirstStage()
    // Load view
    viewModel.didAppear()
    // Should enter final on boarding stage
    assertFinalStage()
  }

  func testCancelFinalStage() {
    viewModel.didAppear()
    doingFirstStage()
    // Hit "done" on keyboard
    expect(self.viewModel.nameFieldDidReturn()).to(beTrue())
    assertFinalStage()
    // Edit name again
    viewModel.delegate.makeNameTextFieldFirstResponder()
    // Should cancel final stage
    expect(App.detecionModule.delegate).to(beNil())
    expect(self.viewModel.completionLabelHidden.value).to(beTrue())
  }

  func testCantHidDoneWithInvalidName() {
    viewModel.nameTextField.value = fullName.components(separatedBy: " ")[0]
    // Should not be able to hit done when only first name is typed.
    expect(self.viewModel.nameFieldDidReturn()).to(beFalse())
  }

  func testTypingName() {
    viewModelDelegate.makeNameTextFieldFirstResponder()
    let firstName = StringHelper.extractFirstName(of: fullName)
    let lastName = StringHelper.extractLastName(of: fullName)
    viewModel.didAppear()
    // Type phone number
    viewModelDelegate.shouldValidateNumber = true
    viewModel.numberFieldTextDidChange()
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

  func testTypingPhoneNumber() {
    viewModelDelegate.makeNumberTextFieldFirstResponder()
    viewModel.didAppear()
    viewModel.numberFieldTextDidChange()
    // Hit done
    viewModel.numberFieldDidReturn()
    // Should not focus name yet
    expect(self.viewModelDelegate.nameFocused).to(beFalse())
    // Visual indicator of illegal name
    expect(self.viewModel.numberTextFieldBorderColor.value.value).to(equal(Color.error.value))
    // Show warning with correct text
    expect(self.viewModel.warningLabelHidden.value).to(beFalse())
    expect(self.viewModel.warningLabelText.value).to(equal(OnBoardingViewModel.invalidNumberText))
    // Valid number entered
    viewModelDelegate.shouldValidateNumber = true
    viewModel.numberFieldTextDidChange()
    // Can hit done
    viewModel.numberFieldDidReturn()
    // Visual indicator of valid number
    expect(self.viewModel.numberTextFieldBorderColor.value.value).to(equal(Color.success.value))
    // Hide warning
    expect(self.viewModel.warningLabelHidden.value).to(beTrue())
    // Name becomes first responder
    expect(self.viewModelDelegate.nameFocused).to(beTrue())
  }

  class OnBoardingTestDelegate: OnBoardingDelegate, AuthDelegate {
    var phoneNumber = "123456789"
    var authOk = false
    var authFail = false
    var nameFocused = false
    var numberFocused = false
    var shouldValidateNumber = false
    weak var viewModel: OnBoardingViewModel!

    init(_ viewModel: OnBoardingViewModel) {
      self.viewModel = viewModel
    }

    func makeNameTextFieldFirstResponder() {
      nameFocused = true
      numberFocused = false
      viewModel.didBeginEditing()
    }

    func resignResponders() {
      nameFocused = false
      numberFocused = false
    }

    func didAuthOk() {
      authOk = true
    }

    func didAuthFail() {
      authFail = true
      viewModel.signUpDidFail()
    }

    func makeNumberTextFieldFirstResponder() {
      nameFocused = false
      numberFocused = true
      viewModel.didBeginEditing()
    }

    func isNumberValid() -> Bool {
      return shouldValidateNumber
    }

    func internationalNumber() throws -> String {
      return "+1" + phoneNumber
    }
  }
}
