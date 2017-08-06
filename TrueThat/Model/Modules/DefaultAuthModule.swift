//
//  DefaultAuthModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON

class DefaultAuthModule: AuthModule {
  
  /// Keychain user session key
  static let userKey = "LAST_USER_SESSION"
  let keychain = Keychain()
  
  override func restoreSession() -> User? {
    if let lastSessionData = try? keychain.getData(DefaultAuthModule.userKey),
      lastSessionData != nil {
      return User(json: JSON(lastSessionData!))
    }
    return nil
  }
  
  override func saveSession() {
    if current != nil {
      do {
        try keychain.set(JSON(current!.toDictionary()).rawData(), key: DefaultAuthModule.userKey)
      } catch {
        App.log.error("Could not save user to keychain")
      }
    }
  }
  
  override func deleteSavedSession() {
    do {
      try keychain.remove(DefaultAuthModule.userKey)
    } catch {
      App.log.error("Could not delete user session from the keychain")
    }
  }
}
