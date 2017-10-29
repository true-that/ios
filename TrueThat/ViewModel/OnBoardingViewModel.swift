//
//  OnBoardingViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class OnBoardingViewModel {
  // MARK: Properties
  public static var detectionDelaySeconds = 0.5
  public static let reactionsForDone = Emotion.happy
  public static let invalidNameText = "invalid name"
  public static let invalidNumberText = "invalid number"
  public static let signUpFailedText = "oopsie we had an error 😬"
  public let warningLabelHidden = MutableProperty(true)
  public let warningLabelText = MutableProperty(OnBoardingViewModel.invalidNameText)
  public let loadingImageHidden = MutableProperty(true)
  public let completionLabelHidden = MutableProperty(true)
  public let nameTextFieldBorderColor = MutableProperty(Color.shadow)
  public let nameTextField = MutableProperty("")
  public let numberTextFieldBorderColor = MutableProperty(Color.shadow)
  var delegate: OnBoardingDelegate!
  /// Timer to delay reaction detection.
  var timer: Timer?

  init() {
    nameTextField.producer.on(value: { _ in self.nameFieldTextDidChange() }).start()
  }

  // MARK: Lifecycle
  func didAppear() {
    loadingImageHidden.value = true
    if StringHelper.isValid(fullName: nameTextField.value) && delegate.isNumberValid() {
      delegate.resignResponders()
      finalStage()
    } else if delegate.isNumberValid() {
      delegate.makeNameTextFieldFirstResponder()
    } else {
      delegate.makeNumberTextFieldFirstResponder()
    }
  }

  func didDisappear() {
    App.detecionModule.stop()
    timer?.invalidate()
  }

  // MARK: Methods

  /// Invoked once one of the fields is being edited.
  func didBeginEditing() {
    completionLabelHidden.value = true
    App.detecionModule.delegate = nil
  }

  /// Invoked when the typed name is changed.
  func nameFieldTextDidChange() {
    if StringHelper.isValid(fullName: nameTextField.value) {
      warningLabelHidden.value = true
      nameTextFieldBorderColor.value = Color.success
    } else {
      nameTextFieldBorderColor.value = Color.error
    }
  }

  /// Invoked when the typed number is changed.
  func numberFieldTextDidChange() {
    if delegate.isNumberValid() {
      warningLabelHidden.value = true
      numberTextFieldBorderColor.value = Color.success
    } else {
      numberTextFieldBorderColor.value = Color.error
    }
  }

  /// Invoked when "Done" is hit on the name field
  ///
  /// - Returns: whether the return should proceed.
  func nameFieldDidReturn() -> Bool {
    if StringHelper.isValid(fullName: nameTextField.value) {
      finalStage()
      return true
    } else {
      warningLabelText.value = OnBoardingViewModel.invalidNameText
      warningLabelHidden.value = false
      return false
    }
  }

  /// Invoked when "Done" is hit on the number field
  func numberFieldDidReturn() {
    if delegate.isNumberValid() {
      delegate.makeNameTextFieldFirstResponder()
    } else {
      warningLabelText.value = OnBoardingViewModel.invalidNumberText
      warningLabelHidden.value = false
    }
  }

  /// Invoked following a failed sign up.
  func signUpDidFail() {
    warningLabelText.value = OnBoardingViewModel.signUpFailedText
    warningLabelHidden.value = false
    loadingImageHidden.value = true
  }

  /// Proceed on boarding to final stage, where the user is asked to smile.
  func finalStage() {
    App.log.debug("finalStage")
    delegate.resignResponders()
    timer = Timer.scheduledTimer(withTimeInterval: OnBoardingViewModel.detectionDelaySeconds, repeats: false,
                                 block: { _ in App.detecionModule.delegate = self })
    completionLabelHidden.value = false
    warningLabelHidden.value = true
    App.detecionModule.start()
  }

  /// Doing the actual sign up.
  func signingUp() {
    App.log.debug("signingUp")
    do {
      try App.authModule.signUp(fullName: nameTextField.value, phoneNumber: delegate.internationalNumber())
    } catch {
      App.log.error("Failed to get phone number.")
      delegate.makeNumberTextFieldFirstResponder()
    }
  }
}

protocol OnBoardingDelegate {

  /// Making the name text field first responder
  func makeNameTextFieldFirstResponder()

  /// Making the number text field first responder
  func makeNumberTextFieldFirstResponder()

  /// Resign focus from text fields
  func resignResponders()

  /// - Returns: whether the typed number is a valid one.
  func isNumberValid() -> Bool

  /// - Returns: the typed number in international format.
  func internationalNumber() throws -> String
}

// MARK: ReactionDetectionDelegate
extension OnBoardingViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion, mostLikely: Bool) {
    if reaction == OnBoardingViewModel.reactionsForDone {
      loadingImageHidden.value = false
      signingUp()
      App.detecionModule.delegate = nil
    }
  }
}
