//
//  Colors.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

enum Color {

  case theme
  case secondary
  case shadow
  case lightText
  case success
  case error
  case custom(hexString: String, alpha: Double)

  func withAlpha(_ alpha: Double) -> UIColor {
    return self.value.withAlphaComponent(CGFloat(alpha))
  }
}

extension Color {

  var value: UIColor {
    var instanceColor = UIColor.clear

    switch self {
    case .theme:
      instanceColor = UIColor(hexString: "#eb5971")
    case .secondary:
      instanceColor = UIColor(hexString: "#eb8b46")
    case .shadow:
      instanceColor = UIColor(hexString: "#000000")
    case .lightText:
      instanceColor = UIColor(hexString: "#f8e6f2")
    case .success:
      instanceColor = UIColor(hexString: "#22aa66")
    case .error:
      instanceColor = UIColor(hexString: "#ff4444")
    case let .custom(hexValue, opacity):
      instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
    }
    return instanceColor
  }
}
