//
//  BaseViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Crashlytics
import UIKit

/// Base view controller class for encapsulating poses (such as OnBoarding or Theater)
class BaseViewController: UIViewController {
  // MARK: Properties
  var doAuth = true
  var logTag = "BaseViewController"

  // MARK: Lifecycle
  override func viewDidLoad() {
    logTag = String(describing: type(of: self))
    super.viewDidLoad()
    App.log.debug("\(logTag): viewDidLoad")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("\(logTag): viewWillAppear")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.log.debug("\(logTag): viewDidAppear")
    App.authModule.delegate = self
    if doAuth {
      App.authModule.auth()
    }
    Crashlytics.sharedInstance().setObjectValue(
      logTag, forKey: LoggingKey.viewController.rawValue.snakeCased()!.uppercased())
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("\(logTag): viewWillDisappear")
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.log.debug("\(logTag): viewDidDisappear")
  }
}

extension BaseViewController: AuthDelegate {
  func didAuthOk() {
    App.log.debug("\(logTag): didAuthOk")
  }

  func didAuthFail() {
    App.log.debug("\(logTag): didAuthFail")
    let welcomeViewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "WelcomeScene")
    let segue = UIStoryboardSegue(identifier: "WelcomeSegue", source: self,
                                  destination: welcomeViewController,
                                  performHandler: {
                                    self.present(welcomeViewController, animated: true, completion: {})
    })
    prepare(for: segue, sender: self)
    segue.perform()
  }
}
