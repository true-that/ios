//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ReactableViewModel {
  public let directorName = MutableProperty("Anonymous")
  var model: Reactable!

  // MARK: Initialization
  init(with reactable: Reactable) {
    model = reactable
    if let displayName = model.director?.displayName {
      directorName.value = displayName
    }
  }
}
