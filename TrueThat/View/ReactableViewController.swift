//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class ReactableViewController: UIViewController {
  // MARK: Properties
  public var viewModel: ReactableViewModel?
  
  // MARK: Initialization
  static func instantiate(with viewModel: ReactableViewModel) -> ReactableViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ReactableViewController")
      as! ReactableViewController
    viewController.viewModel = viewModel
    return viewController
  }

  @IBOutlet weak var directorLabel: UILabel!

  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let viewModel = viewModel else {
      return
    }
    
    directorLabel.reactive.text <~ viewModel.directorName
  }
}
