//
//  App.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import SwiftyBeaver

class App {
  public static var authModule = AuthModule()
  
  public static var detecionModule = ReactionDetectionModule()
  
  public static var log: SwiftyBeaver.Type {
    let log = SwiftyBeaver.self
    log.addDestination(ConsoleDestination())
    return log
  }
}
