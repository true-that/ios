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
  public let warningLabelHidden = MutableProperty(true)
  public let completionLabelHidden = MutableProperty(true)
  public let nameTextFieldBorderColor = MutableProperty(Color.shadow)
  public let nameTextField = MutableProperty("")
  var delegate: OnBoardingDelegate!
  
  init() {
    nameTextField.producer.on(value: {name in self.nameFieldTextDidChange()}).start()
  }
  
  // MARK: Lifecycle
  func didAppear() {
    if StringHelper.isValid(fullName: nameTextField.value) {
      delegate.loseNameTextFieldFocus()
      finalStage()
    } else {
      delegate.requestNameTextFieldFocus()
    }
  }
  
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
      warningLabelHidden.value = false
      return false
    }
  }
  
  func finalStage() {
    App.detecionModule.delegate = self
    completionLabelHidden.value = false
  }
}

protocol OnBoardingDelegate {
  func requestNameTextFieldFocus()
  
  func loseNameTextFieldFocus()
  
  func finishOnBoarding(with name: String)
}

// MARK: ReactionDetectionDelegate
extension OnBoardingViewModel: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion) {
    if reaction == OnBoardingViewModel.reactionForDone {
      delegate.finishOnBoarding(with: nameTextField.value)
      App.detecionModule.delegate = nil
    }
  }
}
