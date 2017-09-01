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
  public static let reactionForDone = Emotion.happy
  public static let invalidNameText = "invalid name"
  public static let signUpFailedText = "oopsie we had an error on our end"
  public let warningLabelHidden = MutableProperty(true)
  public let warningLabelText = MutableProperty(OnBoardingViewModel.invalidNameText)
  public let loadingImageHidden = MutableProperty(true)
  public let completionLabelHidden = MutableProperty(true)
  public let nameTextFieldBorderColor = MutableProperty(Color.shadow)
  public let nameTextField = MutableProperty("")
  var delegate: OnBoardingDelegate!
  
  init() {
    nameTextField.producer.on(value: {name in self.nameFieldTextDidChange()}).start()
  }
  
  // MARK: Lifecycle
  func didAppear() {
    loadingImageHidden.value = true
    if StringHelper.isValid(fullName: nameTextField.value) {
      delegate.loseNameTextFieldFocus()
      finalStage()
    } else {
      delegate.requestNameTextFieldFocus()
    }
  }
  
  func didDisappear() {
    App.detecionModule.stop()
  }
  
  // MARK: Methods
  
  func nameFieldDidBeginEditing() {
    completionLabelHidden.value = true
    App.detecionModule.delegate = nil
  }
  
  func nameFieldTextDidChange() {
    if StringHelper.isValid(fullName: nameTextField.value) {
      warningLabelHidden.value = true
      nameTextFieldBorderColor.value = Color.success
    } else {
      nameTextFieldBorderColor.value = Color.error
    }
  }
  
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
  
  func signUpDidFail() {
    warningLabelText.value = OnBoardingViewModel.signUpFailedText
    warningLabelHidden.value = false
    loadingImageHidden.value = true
  }
  
  func finalStage() {
    App.detecionModule.start()
    App.detecionModule.delegate = self
    completionLabelHidden.value = false
    warningLabelHidden.value = true
  }
  
  func signingUp(with name: String) {
    App.authModule.signUp(fullName: name)
  }
}

protocol OnBoardingDelegate {
  func requestNameTextFieldFocus()
  
  func loseNameTextFieldFocus()
}

// MARK: ReactionDetectionDelegate
extension OnBoardingViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion) {
    if reaction == OnBoardingViewModel.reactionForDone {
      loadingImageHidden.value = false
      signingUp(with: nameTextField.value)
      App.detecionModule.delegate = nil
    }
  }
}
