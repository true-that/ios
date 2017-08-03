//
//  SceneViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class SceneViewModel: ReactableViewModel {
  // MARK: Properties
  public var imageUrl: String?
  private var scene: Scene {
    return model as! Scene
  }
  var mediaDelegate: SceneMediaDelegate {
    return delegate as! SceneMediaDelegate
  }
  
  // MARK: Initialization
  override init(with reactable: Reactable) {
    super.init(with: reactable)
    imageUrl = scene.imageUrl
  }
  
  // MARK: Lifecycle
  override func didLoad() {
    super.didLoad()
    mediaDelegate.loadSceneImage()
  }
}

protocol SceneMediaDelegate {
  
  /// Notifies the view controller to load an image from `imageUrl`.
  func loadSceneImage()
}
