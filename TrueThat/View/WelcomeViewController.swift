//
//  WelcomeViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
  
  @IBOutlet weak var signUpLabel: UILabel!
  @IBOutlet weak var signUpImage: UIImageView!
  @IBOutlet weak var signUpStackView: UIStackView!
  @IBOutlet weak var signInLabel: UILabel!
  @IBOutlet weak var errorLabel: UILabel!
  
  override func viewDidLoad() {
    App.log.verbose("viewDidLoad")
    super.viewDidLoad()
    
    // Colors
    signUpLabel.textColor = Color.theme.value
    signInLabel.textColor = Color.theme.value
    errorLabel.textColor = Color.error.value
    
    // Visibility
    errorLabel.isHidden = true
    
    
    // OnClick hooks
    signUpStackView.isUserInteractionEnabled = true
    signUpStackView.accessibilityLabel = "sign up"
    signUpStackView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signUp)))
    signInLabel.isUserInteractionEnabled = true
    signInLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signIn)))
  }
  
  @objc private func signUp() {
    App.log.verbose("They all sign up eventually")
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "OnBoardingScene"),
      animated: true, completion: nil)
  }
  
  @objc private func signIn() {
    
  }
}
