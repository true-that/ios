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

class OnBoardingViewControllerTests: BaseUITests {
  let fullName = "Swa la lala"
  var viewController: OnBoardingViewController!

  func testOnBoardingFlow() {
    // Sets up english locale
    UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
    // Sign out
    App.authModule.delegate = nil
    App.authModule.signOut()
    // Init view controller
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(
      withIdentifier: "OnBoardingScene") as! OnBoardingViewController
    UIApplication.shared.keyWindow!.rootViewController = viewController
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    UITestsHelper.triggeringViewAppearance(viewController)

    let user = User(id: 1, firstName: "swa", lastName: "la lala",
                    deviceId: App.deviceModule.deviceId, phoneNumber: "+1 4155552671")
    // Sets up stub backend response
    stub(condition: isPath(AuthApi.path)) { request -> OHHTTPStubsResponse in
      let requestUser = User(json: JSON(Data(fromStream: request.httpBodyStream!)))
      requestUser.id = 1
      let data = try? JSON(from: requestUser).rawData()
      return OHHTTPStubsResponse(data: data!, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    // Should focus number field
    expect(self.viewController.numberTextField.isFirstResponder).toEventually(beTrue())
    // Type first digit
    tester().enterText(intoCurrentFirstResponder: "4")
    // Try to hit done
    tester().tapView(withAccessibilityLabel: "Done")
    // Indicator of invalid phone number
    expect(self.viewController.numberTextField.layer.borderColor).to(equal(Color.error.value.cgColor))
    expect(self.viewController.warningLabel.isHidden).to(beFalse())
    expect(self.viewController.warningLabel.text).to(equal(OnBoardingViewModel.invalidNumberText))
    // Should still have focus
    expect(self.viewController.numberTextField.isFirstResponder).to(beTrue())
    // Type rest of the number
    tester().enterText(intoCurrentFirstResponder: "155552671")
    // Try to hit done
    tester().tapView(withAccessibilityLabel: "Done")
    // Should focus name field
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
    expect(self.viewController.nameTextField.layer.borderColor).toEventually(equal(Color.success.value.cgColor))
    expect(self.viewController.warningLabel.isHidden).to(beTrue())
    expect(self.viewController.warningLabel.text).to(equal(OnBoardingViewModel.invalidNameText))
    // Dont start detection just yet, wait for hitting "done"
    expect(App.detecionModule.delegate).to(beNil())
    tester().tapView(withAccessibilityLabel: "Join")
    expect(self.viewController.nameTextField.isFirstResponder).toEventually(beFalse())
    // Wait for detection to start
    expect(App.detecionModule.delegate).toEventuallyNot(beNil())
    // Assert final stage
    expect(App.detecionModule.delegate as! OnBoardingViewModel === self.viewController.viewModel).to(beTrue())
    expect(self.viewController.completionLabel.isHidden).to(beFalse())
    // Complete on boarding
    fakeDetectionModule.detect(OnBoardingViewModel.reactionsForDone)
    // Should show loading image
    expect(self.viewController.loadingImage.isHidden).to(beFalse())
    expect(App.authModule.current).toEventually(equal(user))
    // Should navigate to main views.
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(MainTabController.self))
  }
}
