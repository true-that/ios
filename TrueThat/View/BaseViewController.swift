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

  // MARK: UIAlertController

  /// Adds dismissal control, so that alerts can be dismissed when the user tap on the screen outside of the alert
  /// view controller.
  ///
  /// - Parameter toView: for which to add the dismiss control.
  func addDismissControl(_ toView: UIView) {
    let dismissControl = UIControl()
    dismissControl.addTarget(self, action: #selector(self.dismissAlertController), for: .touchDown)
    dismissControl.frame = toView.superview?.frame ?? CGRect.zero
    toView.superview?.insertSubview(dismissControl, belowSubview: toView)
  }

  /// Dismissed open alert controller.
  func dismissAlertController() {
    self.dismiss(animated: true, completion: nil)
  }

  /// Shows alert dialog to the user.
  ///
  /// - Parameters:
  ///   - title: title at the top of the dislogue
  ///   - message: message body of alert
  ///   - okAction: what the user clicks to terminate the dialogue
  func presentAlert(title: String?, message: String?, okAction: String?,
                    preferredStyle: UIAlertControllerStyle = .alert, handler: ((UIAlertAction) -> Swift.Void)? = nil,
                    completion: (() -> Swift.Void)? = nil) {

    // Creates alert controller
    let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    alertController.addAction(UIAlertAction(title: okAction, style: .default) { (alertAction) -> Void in
      handler?(alertAction)
    })

    self.present(alertController, animated: true, completion: {
      self.addDismissControl(alertController.view)
      completion?()
    })
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
