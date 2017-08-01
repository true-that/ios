//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ReactableViewModel {
  public let directorName = MutableProperty("")
  public let timeAgo = MutableProperty("")
  public let reactionEmoji = MutableProperty("")
  public let reactionsCount = MutableProperty("")
  
  var model: Reactable
  var delegate: Any!

  // MARK: Initialization
  init(with reactable: Reactable) {
    model = reactable
    if let displayName = model.director?.displayName {
      directorName.value = displayName
    }
    if model.created != nil {
      timeAgo.value = DateHelper.truncatedTimeAgo(from: model.created!)
    }
    if model.reactionCounters != nil {
      reactionsCount.value = NumberHelper.truncate(Array(model.reactionCounters!.values).reduce(0, +))
      if model.userReaction != nil {
        reactionEmoji.value = model.userReaction!.emoji
      } else {
        reactionEmoji.value = model.reactionCounters!.max{$0.0.value < $0.1.value}!.key.emoji
      }
    }
  }
  
  static func instantiate(with reactable: Reactable) -> ReactableViewModel {
    switch reactable {
    case is Scene:
      return SceneViewModel(with: reactable)
    default:
      return ReactableViewModel(with: reactable)
    }
  }
  
  // MARK: Lifecycle
  public func didLoad() {}
}
