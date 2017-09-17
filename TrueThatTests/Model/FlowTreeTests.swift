//
//  FlowTreeTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 17/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat
import Nimble

class FlowTreeTests: XCTestCase {
  let photo1 = Photo(id: 1, url: "1")
  let photo2 = Photo(id: 2, url: "2")
  let photo3 = Photo(id: 3, url: "3")
  let edge1 = Edge(sourceId: 1, targetId: 2, reaction: .fear)
  let edge2 = Edge(sourceId: 2, targetId: 3, reaction: .happy)
  
  var tree: FlowTree!
  var delegate: FakeFlowTreeDelegate!
  
  override func setUp() {
    super.setUp()
    delegate = FakeFlowTreeDelegate()
    tree = FlowTree(delegate: delegate)
  }
  
  func testAddNode() {
    expect(self.tree.nodes.isEmpty).to(beTrue())
    tree.add(media: photo1)
    expect(self.tree.media(by: self.photo1.id!)).to(equal(photo1))
    tree.add(media: photo2)
    expect(self.tree.media(by: self.photo2.id!)).to(equal(photo2))
    expect(self.tree.nodes.count).to(equal(2))
  }
  
  func testRoot() {
    expect(self.tree.root).to(beNil())
    tree.add(media: photo1)
    expect(self.tree.root).to(equal(photo1))
    tree.add(media: photo2)
    tree.add(edge: edge1)
    expect(self.tree.root).to(equal(photo1))
  }
  
  func testChild() {
    tree.add(media: photo1)
    tree.add(media: photo2)
    tree.add(edge: edge1)
    expect(self.tree.child(of: self.photo1.id!, emotion: self.edge1.reaction!)).to(equal(photo2))
    expect(self.tree.child(of: self.photo2.id!, emotion: .happy)).to(beNil())
  }
  
  func testParent() {
    tree.add(media: photo1)
    tree.add(media: photo2)
    tree.add(edge: edge1)
    expect(self.tree.parent(of: self.photo2.id!)).to(equal(photo1))
  }
  
  func testRemove() {
    tree.add(media: photo1)
    tree.add(media: photo2)
    tree.add(media: photo3)
    tree.add(edge: edge1)
    tree.add(edge: edge2)
    expect(self.tree.remove(at: self.photo2.id!)).to(equal(photo1))
    expect(self.tree.media(by: self.photo2.id!)).to(beNil())
    expect(self.tree.media(by: self.photo3.id!)).to(beNil())
    expect(self.delegate.deletedMedia.contains(self.photo2)).to(beTrue())
    expect(self.delegate.deletedMedia.contains(self.photo3)).to(beTrue())
    expect(self.delegate.deletedEdges.contains(self.edge1)).to(beTrue())
    expect(self.delegate.deletedEdges.contains(self.edge2)).to(beTrue())
  }
  
  func testRemoveRoot() {
    tree.add(media: photo1)
    tree.add(media: photo2)
    tree.add(media: photo3)
    tree.add(edge: edge1)
    tree.add(edge: edge2)
    expect(self.tree.remove(at: self.photo1.id!)).to(beNil())
    expect(self.tree.media(by: self.photo2.id!)).to(beNil())
    expect(self.tree.media(by: self.photo1.id!)).to(beNil())
    expect(self.delegate.deletedMedia.contains(self.photo2)).to(beTrue())
    expect(self.delegate.deletedMedia.contains(self.photo1)).to(beTrue())
  }
  
  func testIsTree() {
    expect(self.tree.isTree).to(beTrue())
    tree.add(media: photo1)
    expect(self.tree.isTree).to(beTrue())
    tree.add(media: photo2)
    expect(self.tree.isTree).to(beFalse())
    tree.add(edge: edge1)
    expect(self.tree.isTree).to(beTrue())
    
  }
  
  class FakeFlowTreeDelegate: FlowTreeDelegate {
    var deletedMedia: [Media] = []
    var deletedEdges: [Edge] = []
    
    func delete(media: Media) {
      deletedMedia.append(media)
    }
    
    func delete(edge: Edge) {
      deletedEdges.append(edge)
    }
  }
}
