//
//  SceneTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat
import Nimble

class SceneTests: BaseTests {
  func testJsonSerialization() {
    let scene = Scene(id: 1, director: User(id: 1, firstName: "android", lastName: "me no like",
                                            deviceId: "iphone", phoneNumber: "+349857"),
                      reactionCounters: [.happy: 1200, .disgust: 800], created: Date(),
                      mediaNodes: [Photo(id: 0, url: "1"), Video(id: 0, url: "2")],
                      edges: [
                        Edge(sourceId: 0, targetId: 1, reaction: .surprise),
                        Edge(sourceId: 1, targetId: 2, reaction: .fear),
    ])
    expect(scene).to(equal(Scene(json: JSON(from: scene))))
  }

  func testUpdateReactionCounters() {
    let reaction = Emotion.happy
    let nilCounters = Scene(id: 1, director: nil, reactionCounters: nil, created: nil, mediaNodes: nil, edges: nil)
    let firstReactionOfType = Scene(id: 1, director: nil, reactionCounters: [.fear: 1], created: nil, mediaNodes: nil,
                                    edges: nil)
    let shouldIncrement = Scene(id: 1, director: nil, reactionCounters: [.happy: 1], created: nil, mediaNodes: nil,
                                edges: nil)
    // Increment counters
    nilCounters.increaseCounter(of: reaction)
    firstReactionOfType.increaseCounter(of: reaction)
    shouldIncrement.increaseCounter(of: reaction)
    // Expected behaviour
    expect(nilCounters.reactionCounters?[reaction]).to(equal(1))
    expect(firstReactionOfType.reactionCounters?[reaction]).to(equal(1))
    expect(shouldIncrement.reactionCounters?[reaction]).to(equal(2))
  }

  func testAddAndRemoveMedia() {
    let photo = Photo(id: nil, url: "1")
    let video = Video(id: nil, url: "2")
    let newVideo = Video(id: nil, url: "3")
    // Creates a scene from a photo
    let scene = Scene(from: photo)
    // Photo should be allocated an ID.
    expect(photo.id).toNot(beNil())
    // Adds a new video to the scene.
    scene.add(media: video, from: photo.id!, on: .disgust)
    // Video should be allocated a unique ID.
    expect(video.id).toNot(beNil())
    expect(video.id).toNot(equal(photo.id))
    // Removes video from the scene
    expect(scene.remove(media: video)).to(equal(photo))
    // Adds a new video to the scene
    scene.add(media: newVideo, from: photo.id!, on: .surprise)
    // new video should follow photo.
    expect(scene.next(of: photo, on: .surprise)).to(equal(newVideo))
  }
}
