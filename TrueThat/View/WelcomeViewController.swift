//
//  WelcomeViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
  
  @IBOutlet weak var signUpLabel: UILabel!
  @IBOutlet weak var signUpImage: UIImageView!
  @IBOutlet weak var signUpStackView: UIStackView!
  @IBOutlet weak var signInLabel: UILabel!
  @IBOutlet weak var errorLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Skip auth
    doAuth = false
    
    // Colors
    signUpLabel.textColor = Color.theme.value
    signInLabel.textColor = Color.theme.value
    errorLabel.textColor = Color.error.value
    
    // Styling
    signUpImage.layer.cornerRadius = 6.0
    signUpImage.clipsToBounds = true
    signUpImage.image = UIImage(named: "AppIcon60x60.png")
    
    // Tap gesture hooks
    signUpStackView.isUserInteractionEnabled = true
    signUpStackView.accessibilityLabel = "sign up"
    signUpStackView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signUp)))
    signInLabel.isUserInteractionEnabled = true
    signInLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signIn)))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Hide warning
    errorLabel.isHidden = true
  }
  
  @objc private func signUp() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "OnBoardingScene"),
      animated: true, completion: nil)
  }
  
  @objc private func signIn() {
    App.authModule.signIn()
  }
  
  override func didAuthOk() {
    super.didAuthOk()
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "TheaterScene"),
      animated: true, completion: nil)
  }

  override func didAuthFail() {
    App.log.verbose("\(logTag): didAuthFail")
    // Show warning
    errorLabel.isHidden = false
  }
}
