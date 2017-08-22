//
//  OnBoardingViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import Nimble
import OHHTTPStubs
import SwiftyJSON

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
    let user = User(id: 1, firstName: "swa", lastName: "la lala",
                    deviceId: App.deviceModule.deviceId)
    // Sets up stub backend response
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(user.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    App.authModule.signOut()
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(WelcomeViewController.self))
    // Navigate to on boarding
    tester().tapView(withAccessibilityLabel: "sign up")
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(OnBoardingViewController.self))
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(OnBoardingViewController.self))
    viewController = UITestsHelper.currentViewController as! OnBoardingViewController
    // Should focus text field
    expect(self.viewController.nameTextField.isFirstResponder).toEventually(beTrue())
    // Warning should be hidden
    expect(self.viewController.warningLabel.isHidden).to(beTrue())
    // Type first name
    tester().enterText(intoCurrentFirstResponder: user.firstName!)
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
    tester().tapView(withAccessibilityLabel: "full name")
    // type last name
    tester().enterText(intoCurrentFirstResponder: " " + user.lastName!)
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
    expect(App.authModule.current).toEventually(equal(user))
    // Should navigate to theater
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(TheaterViewController.self))
  }
}
