//
//  UIImage+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 20/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

extension UIImage {
  // Big hugs to https://stackoverflow.com/a/27775741/4349707
  func fixOrientation() -> UIImage {
    if self.imageOrientation == .up {
      return self
    }

    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    self.draw(in: rect)

    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return normalizedImage
  }
}
