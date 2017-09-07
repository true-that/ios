//
//  PhotoViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewController: MediaViewController {
  // MARK: Properties
  var photo: Photo?
  @IBOutlet weak var imageView: UIImageView!
  
  // MARK: Initialization
  static func instantiate(_ photo: Photo) -> PhotoViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "PhotoScene")
      as! PhotoViewController
    viewController.photo = photo
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.contentMode = UIViewContentMode.scaleAspectFill
    if photo?.url != nil {
      imageView.kf.setImage(with: URL(string: photo!.url!), completionHandler: {
        image, error, cacheType, imageUrl in
        if error != nil {
          App.log.warning("Error when downloading image: \(error!)")
        } else if image == nil {
          App.log.warning("Image is nil")
        } else {
          self.delegate?.didDownloadMedia()
        }
      })
    } else if photo?.data != nil {
      imageView.image = UIImage(data: photo!.data!)
    }
  }
}
