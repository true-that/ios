//
//  UITestsHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
@testable import TrueThat

class UITestsHelper {
  static var currentViewController: UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      return topController
    }
    return nil
  }

  static func triggeringViewAppearance(_ viewController: UIViewController) {
    viewController.beginAppearanceTransition(true, animated: false)
    viewController.endAppearanceTransition()
  }
}
