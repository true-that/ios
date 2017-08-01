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
  var imageUrl: String?
  @IBOutlet weak var sceneImage: UIImageView!
  
  // MARK: Initialization
  static func instantiate(with scene: Scene) -> SceneMediaViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "SceneMediaScene")
      as! SceneMediaViewController
    viewController.imageUrl = scene.imageUrl
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if imageUrl != nil {
      sceneImage.kf.setImage(with: URL(string: imageUrl!))
    }
  }
}
