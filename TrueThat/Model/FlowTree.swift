//
//  FlowTree.swift
//  TrueThat
//
//  Created by Ohad Navon on 14/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FlowTree {

  // MARK: Properties
  var delegate: FlowTreeDelegate!
  /// Maps media IDs to their corresponding nodes.
  var nodes: [Int64: Node] = [:]

  /// Retrieves a root node of the tree.
  var root: Media? {
    var node = nodes.first?.value
    while node?.parent != nil {
      node = node!.parent
    }
    return node?.media
  }

  /// Whether the tree has at most a single root
  var isTree: Bool {
    var numRoots = 0
    for node in nodes.values {
      if node.parent == nil {
        numRoots += 1
      }
    }
    return numRoots <= 1
  }

  // MARK: Initialization
  init(delegate: FlowTreeDelegate) {
    self.delegate = delegate
  }

  // MARK: Methods

  /// Removes the node that is associated with `mediaId` and all its children.
  ///
  /// - Parameter mediaId: to remove.
  /// - Returns: the media of the parent node if one such node exists.
  func remove(at mediaId: Int64) -> Media? {
    var parentMedia: Media?
    if nodes[mediaId] != nil {
      let toRemove = nodes[mediaId]!
      if toRemove.parent != nil {
        parentMedia = toRemove.parent!.media
        delegate.delete(edge: toRemove.parent!.remove(child: toRemove)!)
      }
      for (_, childNode) in toRemove.children {
        _ = remove(at: childNode.media!.id!)
      }
      delegate.delete(media: toRemove.media)
      nodes.removeValue(forKey: mediaId)
    }
    return parentMedia
  }

  /// - Parameter mediaId: of the desired media.
  /// - Returns: the media in this tree that has `mediaId`.
  func media(by mediaId: Int64) -> Media? {
    return nodes[mediaId]?.media
  }

  /// - Parameters:
  ///   - mediaId: of the parent node
  ///   - emotion: that resembles the edge color
  /// - Returns: the child, if any, of the node associates with `mediaId` that is colored by `emotion`.
  func child(of mediaId: Int64, emotion: Emotion) -> Media? {
    return nodes[mediaId]?.children[emotion]?.media
  }

  /// - Parameter mediaId: that is assiciated with the node.
  /// - Returns: the parent node of the node that is associated with
  func parent(of mediaId: Int64) -> Media? {
    return nodes[mediaId]?.parent?.media
  }

  /// Adds a node that contains `media`.
  ///
  /// - Parameter media: to create a node from.
  func add(media: Media) {
    nodes[media.id!] = Node(media: media)
  }

  func add(edge: Edge) {
    if edge.sourceId == nil {
      App.log.report("Edge is missing a source ID", withError: NSError(domain: Bundle.main.bundleIdentifier!,
                                                                       code: ErrorCode.mediaTree.rawValue,
                                                                       userInfo: edge.toDictionary()))
    } else if edge.targetId == nil {
      App.log.report("Edge is missing a target ID", withError: NSError(domain: Bundle.main.bundleIdentifier!,
                                                                       code: ErrorCode.mediaTree.rawValue,
                                                                       userInfo: edge.toDictionary()))
    } else if edge.reaction == nil {
      App.log.report("Edge is missing a reaction", withError: NSError(domain: Bundle.main.bundleIdentifier!,
                                                                      code: ErrorCode.mediaTree.rawValue,
                                                                      userInfo: edge.toDictionary()))
    } else if nodes[edge.sourceId!] == nil {
      App.log.report("Source ID (=\(edge.sourceId!)) does not exist in the tree",
                     withError: NSError(domain: Bundle.main.bundleIdentifier!, code: ErrorCode.mediaTree.rawValue,
                                        userInfo: edge.toDictionary()))
    } else if nodes[edge.targetId!] == nil {
      App.log.report("Target ID (=\(edge.targetId!)) does not exist in the tree",
                     withError: NSError(domain: Bundle.main.bundleIdentifier!, code: ErrorCode.mediaTree.rawValue,
                                        userInfo: edge.toDictionary()))
    } else {
      nodes[edge.sourceId!]!.add(child: nodes[edge.targetId!]!, emotion: edge.reaction!)
    }
  }

  class Node {
    var media: Media!
    var parent: Node?
    var children: [Emotion: Node] = [:]

    init(media: Media) {
      self.media = media
    }

    /// Add a child to this node
    ///
    /// - Parameters:
    ///   - child: to add
    ///   - emotion: color of edge
    func add(child: Node, emotion: Emotion) {
      children[emotion] = child
      child.parent = self
    }

    /// Removes a child node from this node.
    ///
    /// - Parameter node: to remove.
    /// - Returns: the edge that connects this node with `child`.
    func remove(child node: Node) -> Edge? {
      for (emotion, childNode) in children {
        if childNode == node {
          children.removeValue(forKey: emotion)
          return Edge(sourceId: self.media.id, targetId: childNode.media.id, reaction: emotion)
        }
      }
      return nil
    }

    public var description: String { return "Node of \(media.toDictionary())" }
  }
}

// MARK: operator overloading
func == (lhs: FlowTree.Node, rhs: FlowTree.Node) -> Bool {
  return lhs.media == rhs.media
}

protocol FlowTreeDelegate {

  /// Deletes a media.
  ///
  /// - Parameter media: to delete.
  func delete(media: Media)

  /// Deletes an edge.
  ///
  /// - Parameter edge: to delete.
  func delete(edge: Edge)
}
