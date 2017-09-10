//
//  DeviceKeychainModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 21/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import KeychainAccess

class DeviceKeychainModule: KeychainModule {
  let keychain = Keychain()
  
  override func get(_ key: String) -> Data? {
    let data = try? keychain.getData(key)
    return data!
  }
  
  override func save(_ data: Data, key: String) throws {
    try keychain.set(data, key: key)
  }
  
  override func delete(_ key: String) throws {
    try keychain.remove(key)
  }
}
