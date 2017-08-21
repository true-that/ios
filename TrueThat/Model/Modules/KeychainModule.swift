//
//  KeychainModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 21/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class KeychainModule {
  
  /// Retrieves data from keychain.
  ///
  /// - Parameter key: for which to get data
  /// - Returns: the data associated with the key, if the key is not found, then `nil` is returned.
  public func get(for key: String) -> Data? {
    return nil
  }
  
  /// Saves `data` to keychain.
  ///
  /// - Parameters:
  ///   - data: to save
  ///   - key: to associate the `data` for future rerieval.
  public func save(data: Data, for key: String) throws {}
  
  /// Deletes data from keychain that is associated with `key`.
  ///
  /// - Parameter key: for which to delete data.
  public func delete(from key: String) throws {}
}
