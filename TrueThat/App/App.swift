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
  
  public static var log = SingletonLog.shared.log
  
  final class SingletonLog {
    
    // Can't init is singleton
    private init() {
      log = SwiftyBeaver.self
      log.addDestination(ConsoleDestination())
    }
    
    // MARK: Shared Instance
    static let shared = SingletonLog()
    
    var log: SwiftyBeaver.Type
  }
}
