//
//  MainTabController.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
  static let repertoireIndex = 0
  static let studioIndex = 1
  static let theaterIndex = 2
  static var launchIndex = studioIndex

  override func viewDidLoad() {
    super.viewDidLoad()
    // Set this controller as the root one
    UIApplication.shared.delegate!.window!!.rootViewController = self

    // Remove the titles and adjust the inset to account for missing title
    for item in tabBar.items! {
      item.accessibilityLabel = item.title
      item.title = ""
      item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    }
    tabBar.tintColor = Color.theme.withAlpha(0.8)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectedIndex = MainTabController.launchIndex
  }
}
