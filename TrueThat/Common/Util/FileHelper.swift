//
//  FileHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 24/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FileHelper {
  
  /// Deletes the file at `file.path`
  ///
  /// - Parameter file: of the file to delete
  static func delete(file:URL) {
    guard FileManager.default.fileExists(atPath: file.path) else{
      return
    }
    do {
      try FileManager.default.removeItem(atPath: file.path)
    }catch{
      App.log.error("Unable to delete file because of \(error)")
    }
  }
}
