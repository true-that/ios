//
//  PoseMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import Kingfisher

class PoseMediaViewController: UIViewController {
  // MARK: Properties
  var imageUrl: String?
  var delegate: PoseMediaViewControllerDelegate?
  @IBOutlet weak var poseImage: UIImageView!
  
  // MARK: Initialization
  static func instantiate(with pose: Pose) -> PoseMediaViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "PoseMediaScene")
      as! PoseMediaViewController
    viewController.imageUrl = pose.imageUrl
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if imageUrl != nil {
      poseImage.contentMode = UIViewContentMode.scaleAspectFill
      poseImage.kf.setImage(with: URL(string: imageUrl!), completionHandler: {
        image, error, cacheType, imageUrl in
        if error != nil {
          App.log.warning("Error when downloading pose image: \(error!)")
        } else if image == nil {
          App.log.warning("Pose image is nil")
        } else {
          self.delegate?.didDownloadMedia()
        }
      })
    }
  }
}

protocol PoseMediaViewControllerDelegate {
  
  /// Invoked once the pose image had been successfully downloaded.
  func didDownloadMedia()
}
