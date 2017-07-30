//
//  ViewTestsUtil.swift
//  TrueThat
//
//  Created by Ohad Navon on 30/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class ViewTestsUtil {
  public static var currentViewController: UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      return topController
    }
    return nil
  }
}
