//
//  UIHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

public class UIHelper {
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
}
