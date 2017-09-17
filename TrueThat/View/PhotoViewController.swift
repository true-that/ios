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
  static var finishTimeoutSeconds = 1.0
  // MARK: Properties
  var photo: Photo?
  var timer: Timer?
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
        image, error, _, _ in
        if error != nil {
          App.log.warning("Error when downloading image: \(error!)")
        } else if image == nil {
          App.log.warning("Image is nil")
        } else {
          self.didDownload()
        }
      })
    } else if photo?.data != nil {
      imageView.image = UIImage(data: photo!.data!)
      didDownload()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    timer?.invalidate()
  }
  
  fileprivate func didDownload() {
    timer = Timer.scheduledTimer(withTimeInterval: PhotoViewController.finishTimeoutSeconds, repeats: false,
                                 block: { _ in
                                  self.finished = true
                                  self.delegate?.didFinish()
    })
    delegate?.didDownloadMedia()
  }
}
