//
//  MediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class MediaViewController: NestedViewController {
  // MARK: Properties
  var delegate: MediaViewControllerDelegate?
  var finished = false
  var media: Media!

  // MARK: Initialization
  public static func instantiate(with media: Media?) -> MediaViewController? {
    var viewController: MediaViewController?
    switch media {
    case is Video:
      viewController = VideoViewController.instantiate(media as! Video)
    case is Photo:
      viewController = PhotoViewController.instantiate(media as! Photo)
    default:
      return nil
    }
    if viewController != nil {
      viewController!.media = media!
    }
    return viewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    guard media.id != nil else {
      App.log.warning("media missing ID")
      return
    }
    logTag += " \(media.id!)"
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
