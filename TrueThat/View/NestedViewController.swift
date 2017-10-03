//
//  NestedViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/10/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class NestedViewController: UIViewController {

  /// Visibility state of this view. Should be controlled externally, for example in page view controllers.
  var isVisible = false {
    didSet {
      if isVisible && !oldValue {
        if isViewLoaded && view.window != nil {
          viewDidShow()
        }
      } else if !isVisible && oldValue {
        viewDidHide()
      }
    }
  }
  var logTag = "NestedViewController"

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
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("\(logTag): viewWillDisappear")
    isVisible = false
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.log.debug("\(logTag): viewDidDisappear")
    isVisible = false
  }

  func viewDidShow() {
    App.log.debug("\(logTag): viewDidShow")
  }

  func viewDidHide() {
    App.log.debug("\(logTag): viewDidHide")
  }
}
