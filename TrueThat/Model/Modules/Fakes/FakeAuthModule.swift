//
//  FakeAuthModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FakeAuthModule: AuthModule {
  var lastSession: User?
  
  override func restoreSession() -> User? {
    return lastSession
  }
  
  override func saveSession() {
    lastSession = current
  }
  
  override func deleteSavedSession() {
    lastSession = nil
  }
}
