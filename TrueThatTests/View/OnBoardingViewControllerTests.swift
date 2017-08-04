//
//  OnBoardingViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class OnBoardingViewControllerTests : BaseUITests {
  let fullName = "Swa la lala"
  var viewController: OnBoardingViewController!
  
  override func setUp() {
    super.setUp()
    
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "OnBoardingScene") as! OnBoardingViewController
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }
  
  func testSuccessfulOnBoarding() {
    let firstName = StringHelper.extractFirstName(of: fullName)
    let lastName = StringHelper.extractLastName(of: fullName)
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    // Should focus text field
    expect(self.viewController.nameTextField.isFirstResponder).toEventually(beTrue())
    // Warning should be hidden
    expect(self.viewController.warningLabel.isHidden).to(beTrue())
    // Type first name
    tester().enterText(intoCurrentFirstResponder: firstName)
    // Try to hit done
    tester().tapView(withAccessibilityLabel: "Join")
    // Should still have focus
    expect(self.viewController.nameTextField.isFirstResponder).to(beTrue())
    // Indicator of invalid full name
    expect(self.viewController.nameTextField.layer.borderColor).to(equal(Color.error.value.cgColor))
    expect(self.viewController.warningLabel.isHidden).to(beFalse())
    // Dont start detection yet
    expect(App.detecionModule.delegate).to(beNil())
    // Regain focus on name field
    tester().tapView(withAccessibilityLabel: "full name field")
    // type last name
    tester().enterText(intoCurrentFirstResponder: " " + lastName)
    // Visual indicator of a valid full name
    expect(self.viewController.nameTextField.layer.borderColor).to(equal(Color.success.value.cgColor))
    expect(self.viewController.warningLabel.isHidden).to(beTrue())
    // Dont start detection just yet, wait for hitting "done"
    expect(App.detecionModule.delegate).to(beNil())
    tester().tapView(withAccessibilityLabel: "Join")
    expect(self.viewController.nameTextField.isFirstResponder).toEventually(beFalse())
    // Start final stage
    expect(App.detecionModule.delegate as! OnBoardingViewModel === self.viewController.viewModel).to(beTrue())
    expect(self.viewController.completionLabel.isHidden).to(beFalse())
    // Complete on boarding
    fakeDetectionModule.detect(OnBoardingViewModel.reactionForDone)
    expect(self.authModule.currentUser.displayName)
      .to(equal(StringHelper.toTitleCase(self.fullName)))
  }
}
