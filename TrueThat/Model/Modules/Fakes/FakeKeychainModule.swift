//
//  FakeKeychainModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 21/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FakeKeychainModule: KeychainModule {
  var fakeKeychain: [String: Data] = [:]
  
  override func get(for key: String) -> Data? {
    return fakeKeychain[key]
  }
  
  override func save(data: Data, for key: String) throws {
    fakeKeychain[key] = data
  }
  
  override func delete(from key: String) throws {
    fakeKeychain[key] = nil
  }
}
