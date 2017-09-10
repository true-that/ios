//
//  InteractionApi.swift
//  TrueThat
//
//  Created by Ohad Navon on 02/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import SwiftyJSON

/// [backend endpoint]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/servlet/InteractionServlet.java
/// Api interface to inform our [backend endpoint] of user interaction with scenes.
class InteractionApi {
  /// Subpath relative to base backend endpoint.
  public static let path = "/interaction"

  /// Full URL of backend endpoint.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + InteractionApi.path
  }

  /// Saves the provided interaction event in our heart touching backend.
  ///
  /// - Parameter interaction: to save
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func save(interaction: InteractionEvent) -> SignalProducer<InteractionEvent, NSError> {
    return SignalProducer { observer, _ in
      var request = try! URLRequest(url: InteractionApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: interaction).rawData()
      // TODO: cancel request when view disappears
      Alamofire.request(request).responseJSON(completionHandler: { response in
        switch response.result {
        case .success:
          observer.send(value: InteractionEvent(json: JSON(response.result.value!)))
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      }).log()
    }
  }
}
