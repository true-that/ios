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
    App.log.debug("sign up - fresh meat!")
    performSegue(withIdentifier: "OnBoardingSegue", sender: self)
  }

  @objc private func signIn() {
    App.authModule.signIn()
  }
}

// MARK: AuthDelegate
extension WelcomeViewController {
  override func didAuthOk() {
    super.didAuthOk()
    performSegue(withIdentifier: "TheaterSegue", sender: self)
  }

  override func didAuthFail() {
    App.log.debug("\(logTag): didAuthFail")
    // Show warning
    errorLabel.isHidden = false
  }
}
