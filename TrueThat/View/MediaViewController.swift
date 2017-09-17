//
//  MediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {
  var delegate: MediaViewControllerDelegate?
  var finished = false

  public static func instantiate(with media: Media?) -> MediaViewController? {
    switch media {
    case is Video:
      return VideoViewController.instantiate(media as! Video)
    case is Photo:
      return PhotoViewController.instantiate(media as! Photo)
    default:
      return nil
    }
  }
}

protocol MediaViewControllerDelegate {

  /// Invoked once the video had been successfully downloaded.
  func didDownloadMedia()

  /// Show loading image to indicate content is being downloaded
  func showLoader()

  /// Hide loading image
  func hideLoader()
  
  /// Invoked once the media is finished, such as when a video ends.
  func didFinish()
}
