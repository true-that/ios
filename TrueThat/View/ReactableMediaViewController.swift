//
//  ReactableMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class ReactableMediaViewController: UIViewController {
  var delegate: ReactableMediaViewControllerDelegate?
  
  public static func instantiate(with reactable: Reactable) -> ReactableMediaViewController? {
    switch reactable {
    case is Short:
      return ShortMediaViewController.instantiate(reactable as! Short)
    case is Pose:
      return PoseMediaViewController.instantiate(reactable as! Pose)
    default:
      return nil
    }
  }
}
