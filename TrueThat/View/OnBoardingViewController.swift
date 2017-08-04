//
//  OnBoardingViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftyBeaver

class OnBoardingViewController: UIViewController {
  // MARK: Properties
  var viewModel: OnBoardingViewModel!
  
  @IBOutlet weak var warningLabel: UILabel!
  @IBOutlet weak var whatsYourNameLabel: UILabel!
  @IBOutlet weak var createAccountLabel: UILabel!
  @IBOutlet weak var completionLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if viewModel == nil {
      viewModel = OnBoardingViewModel()
      viewModel.delegate = self
    }
    // Sets up colors
    warningLabel.textColor = Color.error.value
    whatsYourNameLabel.textColor = Color.theme.value
    createAccountLabel.textColor = Color.theme.value
    completionLabel.textColor = Color.theme.value
    nameTextField.textColor = Color.theme.value
    nameTextField.layer.borderWidth = 1.0
    viewModel.nameTextFieldBorderColor.producer
      .on(value: {self.nameTextField.layer.borderColor = $0.cgColor})
      .start()
    nameTextField.delegate = self
    
    // Sets up visibility
    warningLabel.reactive.isHidden <~ viewModel.warningLabelHidden
    warningLabel.isHidden = true
    completionLabel.reactive.isHidden <~ viewModel.completionLabelHidden
    completionLabel.isHidden = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.didAppear()
    App.detecionModule.start()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.detecionModule.stop()
  }
}

// MARK: OnBoardingDelegate
extension OnBoardingViewController: OnBoardingDelegate {
  func requestNameTextFieldFocus() {
    nameTextField.becomeFirstResponder()
  }
  
  func loseNameTextFieldFocus() {
    nameTextField.resignFirstResponder()
  }
  
  func finishOnBoarding(with name: String) {
    App.authModule.signUp(fullName: name)
  }
}

// MARK: UITextFieldDelegate
extension OnBoardingViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    viewModel.nameTextField.value = nameTextField.text!
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    viewModel.nameTextField.value = nameTextField.text!
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    viewModel.nameFieldDidBeginEditing()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if viewModel.nameFieldDidReturn() {
      nameTextField.resignFirstResponder()
      return true
    }
    return false
  }
}
