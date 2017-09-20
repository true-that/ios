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
/// Api interface to save scenes to out [backend].
class StudioApi {
  /// Subpath relative to base backend endpoint.
  public static let path = "/studio"

  /// Scene part name when uploading a directed scene
  static let scenePart = "scene"

  /// Media part name of an uploaded scene
  static let mediaPartPrefix = "media_"

  /// Full URL of backend endpoint.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + StudioApi.path
  }

  /// Saves the scene to our backend
  ///
  /// - Parameter scene: to save
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func save(scene: Scene) -> SignalProducer<Scene, NSError> {
    // TODO: cancel request when view disappears
    return SignalProducer { observer, _ in
      let request = try! URLRequest(url: StudioApi.fullUrl, method: .post)
      App.log.info("MULTIPART \(StudioApi.fullUrl)")
      Alamofire.upload(multipartFormData: { multipartFormData in
        scene.appendTo(multipartFormData: multipartFormData)
      }, with: request,
      encodingCompletion: { result in
        // The result of craeting a data request
        switch result {
        case let .success(upload, _, _):
          // The actual network HTTP communication is done here.
          upload.responseJSON { response in
            switch response.result {
            case .success:
              observer.send(value: Scene(json: JSON(response.result.value!)))
              observer.sendCompleted()
            case .failure:
              App.log.error("response error")
              observer.send(error: response.result.error as NSError!)
            }
          }
        case let .failure(encodingError):
          App.log.error("encoding error")
          observer.send(error: encodingError as NSError!)
        }
      })
    }
  }
}
