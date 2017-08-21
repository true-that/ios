//
//  SceneMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import Kingfisher

class SceneMediaViewController: UIViewController {
  // MARK: Properties
  var imageSignedUrl: String?
  var delegate: SceneMediaViewControllerDelegate?
  @IBOutlet weak var sceneImage: UIImageView!
  
  // MARK: Initialization
  static func instantiate(with scene: Scene) -> SceneMediaViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "SceneMediaScene")
      as! SceneMediaViewController
    viewController.imageSignedUrl = scene.imageSignedUrl
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if imageSignedUrl != nil {
      sceneImage.contentMode = UIViewContentMode.scaleAspectFill
      sceneImage.kf.setImage(with: URL(string: imageSignedUrl!), completionHandler: {
        image, error, cacheType, imageSignedUrl in
        if error != nil {
          App.log.warning("Error when downloading scene image: \(error!)")
        } else if image == nil {
          App.log.warning("Scene image is nil")
        } else {
          self.delegate?.didDownloadMedia()
        }
      })
    }
  }
}

protocol SceneMediaViewControllerDelegate {
  
  /// Invoked once the scene image had been successfully downloaded.
  func didDownloadMedia()
}
