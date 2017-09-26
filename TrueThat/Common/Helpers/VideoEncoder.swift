//
//  VideoEncoder.swift
//  TrueThat
//
//  Created by Ohad Navon on 20/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import AVFoundation
import ReactiveSwift

/// Encodes a native .mov format into compressed .mp4 one. Big hugs to https://stackoverflow.com/a/39329155/4349707
class VideoEncoder {
  static func encode(videoUrl: URL) -> SignalProducer<URL, NSError> {
    let avAsset = AVURLAsset(url: videoUrl)
    let resultFileName = "\(UUID()).mp4"
    let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)

    let resultDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    let resultPath = resultDir.appendingPathComponent(resultFileName)

    exportSession?.outputURL = resultPath
    exportSession?.outputFileType = AVFileTypeMPEG4
    exportSession?.shouldOptimizeForNetworkUse = true

    let start = CMTimeMakeWithSeconds(0.0, 0)
    let range = CMTimeRange(start: start, duration: avAsset.duration)
    exportSession?.timeRange = range

    return SignalProducer { observer, _ in
      guard exportSession != nil else {
        App.log.error("Failed to create export seession.")
        observer.send(error: NSError(domain: Bundle.main.bundleIdentifier!, code: ErrorCode.exportSession.rawValue,
                                     userInfo: nil))
        return
      }
      exportSession!.exportAsynchronously{() -> Void in
        switch exportSession!.status{
        case .failed:
          observer.send(error: exportSession!.error! as NSError)
        case .cancelled:
          App.log.debug("Video encoding cancelled")
          observer.sendInterrupted()
        case .completed:
          if exportSession?.outputURL == nil {
            observer.send(error: NSError(domain: Bundle.main.bundleIdentifier!, code: ErrorCode.videoEncoding.rawValue,
                                         userInfo: nil))
          } else {
            observer.send(value: exportSession!.outputURL!)
            observer.sendCompleted()
            App.log.debug("Video successfully encoded to \(exportSession!.outputURL!)")
          }
        default:
          break
        }
      }
    }
  }
}

