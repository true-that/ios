//
//  StudioApi.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/servlet/StudioServlet.java
/// Api interface to save reactables to out [backend].
class StudioApi {
  /// Subpath relative to base backend endpoint.
  static public let path = "/studio"
  
  /// Full URL of backend endpoint.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + StudioApi.path
  }
  /// Saves the reactable to our backend
  ///
  /// - Parameter reactable: to save
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func save(reactable: Reactable) -> SignalProducer<Reactable, NSError> {
    // TODO: cancel request when view disappears
    return SignalProducer { observer, disposable in
      let request = try! URLRequest(url: StudioApi.fullUrl, method: .post)
      Alamofire.upload(multipartFormData: { multipartFormData in
        App.log.info("MULTIPART \(StudioApi.fullUrl)")
        reactable.appendTo(multipartFormData: multipartFormData)
      }, with: request,
         encodingCompletion: {result in
          // The result of craeting a data request
          switch result {
          case .success(let upload, _, _):
            // The actual network HTTP communication is done here.
            upload.responseJSON{ response in
              switch response.result {
              case .success:
                let saved = Reactable.instantiate(with: JSON(response.result.value!))
                if saved != nil {
                  observer.send(value: saved!)
                  observer.sendCompleted()
                } else {
                  App.log.error("response decoding error")
                  observer.send(error: NSError(domain: BaseError.domain,
                                               code: BaseError.network.hashValue, userInfo: nil))
                }
              case .failure:
                App.log.error("response error")
                observer.send(error: response.result.error as NSError!)
              }
            }
          case .failure(let encodingError):
            App.log.error("encoding error")
            observer.send(error: encodingError as NSError!)
          }
      })
    }
  }
}
