//
//  OnBoardingViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble


class OnBoardingViewModelTests: BaseTests {
  let fullName = "Jack Sparrow"
  var viewModel: OnBoardingViewModel!
  var viewModelDelegate: OnBoardingTestDelegate!
  
  override func setUp() {
    super.setUp()
    fakeAuthModule.signOut()
    viewModel = OnBoardingViewModel()
    viewModelDelegate = OnBoardingTestDelegate(viewModel)
    viewModel.delegate = viewModelDelegate
    App.detecionModule.start()
  }
  
  func assertFinalStage() {
    // Should be listening to reaction detection.
    expect(App.detecionModule.delegate as! OnBoardingViewModel === self.viewModel).to(beTrue())
    // Should show "smile to complete" text
    expect(self.viewModel.completionLabelHidden.value).to(beFalse())
    // Warning should be hidden
    expect(self.viewModel.warningLabelHidden.value).to(beTrue())
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
    fakeDetectionModule.detect(OnBoardingViewModel.reactionForDone)
    // On boarding is finished
    expect(self.viewModelDelegate.onBoardingFinished).to(beTrue())
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
    // Show warning
    expect(self.viewModel.warningLabelHidden.value).to(beFalse())
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
  
  class OnBoardingTestDelegate: OnBoardingDelegate {
    var nameTextFieldFocused = false
    var onBoardingFinished = false
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
    
    func finishOnBoarding(with name: String) {
      onBoardingFinished = true
    }
  }
}
