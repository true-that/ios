//
//  VideoEncoder.swift
//  TrueThat
//
//  Created by Ohad Navon on 20/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import AVFoundation

class VideoEncoder {
  static func encodeVideo(videoURL: URL) {
    let avAsset = AVURLAsset(url: videoURL)
    let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
    
    let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
    
    let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
    
    let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
    deleteFile(filePath!)
    
    if FileManager.default.fileExists(atPath: myDocPath!){
      do{
        try FileManager.default.removeItem(atPath: myDocPath!)
      }catch let error{
        print(error)
      }
    }
    
    exportSession?.outputURL = filePath
    exportSession?.outputFileType = AVFileTypeMPEG4
    exportSession?.shouldOptimizeForNetworkUse = true
    
    let start = CMTimeMakeWithSeconds(0.0, 0)
    let range = CMTimeRange(start: start, duration: avAsset.duration)
    exportSession?.timeRange = range
    
    exportSession!.exportAsynchronously{() -> Void in
      switch exportSession!.status{
      case .failed:
        App.log.error("\(exportSession!.error!)")
      case .cancelled:
        App.log.debug("Video encoding cancelled")
      case .completed:
        App.log.debug("Video successfully encoded to \(exportSession!.outputURL!)")
      default:
        break
      }
      
    }
  }
  
  static func deleteFile(_ filePath:URL) {
    guard FileManager.default.fileExists(atPath: filePath.path) else{
      return
    }
    do {
      try FileManager.default.removeItem(atPath: filePath.path)
    }catch{
      fatalError("Unable to delete file: \(error) : \(#function).")
    }
  }
}
