//
//  UIHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

public class UIHelper {

  /// Initialize our beautiful loading image.
  ///
  /// - Parameter imageView: in which to initialize the loading animation.
  public static func initLoadingImage(_ imageView: UIImageView) {
    var images: [UIImage] = []
    for i in 0 ... 44 {
      images.append(UIImage(named: "anim_loading_\(i)")!)
    }
    imageView.animationImages = images
    imageView.animationDuration = 0.8
    imageView.startAnimating()
    // Brings loading image to front
    imageView.superview?.bringSubview(toFront: imageView)
  }

  /// Removes a view controller from its parrent
  ///
  /// - Parameter viewController: to remove
  public static func remove(viewController: UIViewController) {
    if viewController is NestedViewController {
      (viewController as! NestedViewController).isVisible = false
    }
    viewController.willMove(toParentViewController: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParentViewController()
  }
}
