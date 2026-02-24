//
//  ZoomedAssetModel.swift
//  Leben in Deutschland
//
//  Identifiable wrapper for an asset name, used when presenting full-screen zoomed images.
//

import Foundation

/// Identifiable model for presenting an image asset in full-screen zoom view.
struct ZoomedAssetModel: Identifiable {
    let id = UUID()
    let name: String
}

/// Convenience typealias for concise usage.
typealias ZoomedAsset = ZoomedAssetModel
