//
//  BaseViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

/// Base view controller class for encapsulating scenes (such as OnBoarding or Theater)
class BaseViewController: UIViewController {
  var doAuth = true
  var logTag = "BaseViewController"
  
  override func viewDidLoad() {
    logTag = String(describing: type(of: self))
    super.viewDidLoad()
    App.log.verbose("\(logTag): viewDidLoad")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.verbose("\(logTag): viewWillAppear")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.log.verbose("\(logTag): viewDidAppear")
    App.authModule.delegate = self
    if doAuth {
      App.authModule.auth()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.verbose("\(logTag): viewWillDisappear")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.log.verbose("\(logTag): viewDidDisappear")
  }
}

extension BaseViewController: AuthDelegate {
  func didAuthOk() {
    App.log.verbose("\(logTag): didAuthOk")
  }
  
  func didAuthFail() {
    App.log.verbose("\(logTag): didAuthFail")
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "WelcomeScene"),
      animated: true, completion: nil)
  }
}
