//
//  Data+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

extension Data {
  init(fromStream input: InputStream) {
    self.init()
    input.open()

    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    while input.hasBytesAvailable {
      let read = input.read(buffer, maxLength: bufferSize)
      if read == 0 {
        break // added
      }
      self.append(buffer, count: read)
    }
    buffer.deallocate(capacity: bufferSize)

    input.close()
  }
}
