//
//  PoseMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import Kingfisher

class PoseMediaViewController: ReactableMediaViewController {
  // MARK: Properties
  var pose: Pose?
  @IBOutlet weak var poseImage: UIImageView!
  
  // MARK: Initialization
  static func instantiate(_ pose: Pose) -> PoseMediaViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "PoseMediaScene")
      as! PoseMediaViewController
    viewController.pose = pose
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    poseImage.contentMode = UIViewContentMode.scaleAspectFill
    if pose?.imageUrl != nil {
      poseImage.kf.setImage(with: URL(string: pose!.imageUrl!), completionHandler: {
        image, error, cacheType, imageUrl in
        if error != nil {
          App.log.warning("Error when downloading pose image: \(error!)")
        } else if image == nil {
          App.log.warning("Pose image is nil")
        } else {
          self.delegate?.didDownloadMedia()
        }
      })
    } else if pose?.imageData != nil {
      poseImage.image = UIImage(data: pose!.imageData!)
    }
  }
}

