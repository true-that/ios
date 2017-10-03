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
  var photo: Photo? {
    if media != nil {
      return media as? Photo
    }
    return nil
  }
  var timer: Timer?
  @IBOutlet weak var imageView: UIImageView!

  // MARK: Initialization
  static func instantiate(_ photo: Photo) -> PhotoViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "PhotoScene")
      as! PhotoViewController
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
      // If displaying photo from camera, then flip it.
      imageView.image = UIImage(data: photo!.data!)?.imageFlippedForRightToLeftLayoutDirection()
      didDownload()
    }

    imageView.isUserInteractionEnabled = true
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

  // MARK: View Controller Navigation
  @objc private func navigateToStudio() {
    App.log.warning("trying to segue")
  }
}
