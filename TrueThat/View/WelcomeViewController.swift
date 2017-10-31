//
//  WelcomeViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
  // MARK: Properties
static let failedSignInDialogOkAction = "Alrighty"
  static let failedSignInDialogTitle = "Good lord!"
  static let failedSignInDialogMessage = "Sign in failed. Invited to join us!"

  var videoViewController: VideoViewController!
  @IBOutlet weak var signInLabel: UILabel!
  @IBOutlet weak var joinButton: UIButton!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Skip auth
    doAuth = false

    // Colors
    signInLabel.textColor = Color.theme.value

    // Tap gesture hooks
    joinButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signUp)))
    signInLabel.isUserInteractionEnabled = true
    signInLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.signIn)))

    // Init background video
    videoViewController = MediaViewController.instantiate(with: Video(resourceName: "welcome")) as! VideoViewController
    addChildViewController(videoViewController)
    view.addSubview(videoViewController.view)
    view.sendSubview(toBack: videoViewController.view)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    videoViewController.viewDidShow()
    if App.authModule.isAuthOk {
      performSegue(withIdentifier: "TheaterSegue", sender: self)
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    videoViewController.viewDidHide()
  }

  // MARK: Actions
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
    // Show error dialog
    presentAlert(title: WelcomeViewController.failedSignInDialogTitle,
                 message: WelcomeViewController.failedSignInDialogMessage,
                 okAction: WelcomeViewController.failedSignInDialogOkAction)
  }
}
