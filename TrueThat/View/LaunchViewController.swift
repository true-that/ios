//
//  LaunchViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class LaunchViewController: BaseViewController {

  @IBOutlet weak var loadingImage: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.authModule.delegate = self
//    App.authModule.auth()
//    App.authModule.signIn()
    didAuthOk()
  }
}

extension LaunchViewController: AuthDelegate {
  func didAuthOk() {
    App.log.debug("didAuthOk")
    performSegue(withIdentifier: "MainSegue", sender: self)
  }

  func didAuthFail() {
    App.log.debug("didAuthFail")
    performSegue(withIdentifier: "WelcomeSegue", sender: self)
  }
}
