//
//  JSON+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyJSON

extension JSON {
  init(from model: BaseModel) {
    var dictionary = model.toDictionary()
    dictionary["type"] = String(describing: type(of: model))
    self.init(dictionary: dictionary)
  }
}
