//
//  OnBoardingViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import PhoneNumberKit
import UIKit
import ReactiveSwift
import ReactiveCocoa

class OnBoardingViewController: BaseViewController {
  // MARK: Properties
  var viewModel: OnBoardingViewModel!
  var phoneNumberKit: PhoneNumberKit!

  @IBOutlet weak var warningLabel: UILabel!
  @IBOutlet weak var whatsYourNumberLabel: UILabel!
  @IBOutlet weak var whatsYourNameLabel: UILabel!
  @IBOutlet weak var createAccountLabel: UILabel!
  @IBOutlet weak var completionLabel: UILabel!
  @IBOutlet weak var numberTextField: PhoneNumberTextField!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var loadingImage: UIImageView!
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if viewModel == nil {
      viewModel = OnBoardingViewModel()
      viewModel.delegate = self
    }

    // Skip auth
    doAuth = false

    // Initializes phone kit
    phoneNumberKit = PhoneNumberKit()

    initColors()
    initTextFields()
    initVisibility()
    addDoneButton()

    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.didAppear()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.didDisappear()
  }

  // MARK: Initialization
  /// Sets up visibility
  func initVisibility() {
    warningLabel.reactive.isHidden <~ viewModel.warningLabelHidden
    warningLabel.isHidden = true
    loadingImage.reactive.isHidden <~ viewModel.loadingImageHidden
    loadingImage.isHidden = true
    completionLabel.reactive.isHidden <~ viewModel.completionLabelHidden
    completionLabel.isHidden = true
  }

  /// Initialize text fields
  func initTextFields() {
    nameTextField.layer.borderWidth = 1.0
    nameTextField.layer.cornerRadius = 3.0
    viewModel.nameTextFieldBorderColor.producer
      .on(value: { self.nameTextField.layer.borderColor = $0.value.cgColor })
      .start()
    nameTextField.delegate = self

    numberTextField.layer.borderWidth = 1.0
    numberTextField.layer.cornerRadius = 3.0
    viewModel.numberTextFieldBorderColor.producer
      .on(value: { self.numberTextField.layer.borderColor = $0.value.cgColor })
      .start()
    numberTextField.delegate = self
    // Sets up warning text
    warningLabel.reactive.text <~ viewModel.warningLabelText
  }

  /// Sets up colors
  func initColors() {
    warningLabel.textColor = Color.error.value
    whatsYourNumberLabel.textColor = Color.theme.value
    whatsYourNameLabel.textColor = Color.theme.value
    createAccountLabel.textColor = Color.theme.value
    completionLabel.textColor = Color.theme.value
    nameTextField.textColor = Color.theme.value
    numberTextField.textColor = Color.theme.value
  }

  func addDoneButton() {
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self, action: #selector(self.numberFieldDidReturn))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    numberTextField.inputAccessoryView = keyboardToolbar
  }

  // MARK: Actions
  @objc private func numberFieldDidReturn() {
    viewModel.numberFieldDidReturn()
  }
}

// MARK: OnBoardingDelegate
extension OnBoardingViewController: OnBoardingDelegate {
  func makeNameTextFieldFirstResponder() {
    nameTextField.becomeFirstResponder()
  }

  func makeNumberTextFieldFirstResponder() {
    numberTextField.becomeFirstResponder()
  }

  func resignResponders() {
    nameTextField.resignFirstResponder()
    numberTextField.resignFirstResponder()
  }

  func isNumberValid() -> Bool {
    return numberTextField.isValidNumber
  }

  func internationalNumber() throws -> String {
    return try phoneNumberKit.format(phoneNumberKit.parse(numberTextField.text!), toType: .international).replacingOccurrences(of: "-", with: "")
  }
}

// MARK: AuthDelegate
extension OnBoardingViewController {
  override func didAuthOk() {
    super.didAuthOk()
    performSegue(withIdentifier: "TheaterSegue", sender: self)
  }

  override func didAuthFail() {
    App.log.verbose("didAuthFail")
    viewModel.signUpDidFail()
  }
}

// MARK: UITextFieldDelegate
extension OnBoardingViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == nameTextField {
      viewModel.nameTextField.value = nameTextField.text!
    } else if textField == numberTextField {
      viewModel.numberFieldTextDidChange()
    }
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == nameTextField {
      viewModel.nameTextField.value = nameTextField.text!
    } else if textField == numberTextField {
      viewModel.numberFieldTextDidChange()
    }
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    viewModel.didBeginEditing()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameTextField {
      if viewModel.nameFieldDidReturn() {
        nameTextField.resignFirstResponder()
        return true
      }
    }
    return false
  }
}
