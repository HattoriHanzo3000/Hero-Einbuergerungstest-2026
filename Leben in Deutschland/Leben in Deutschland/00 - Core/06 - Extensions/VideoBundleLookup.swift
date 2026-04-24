//
//  VideoBundleLookup.swift
//  Leben in Deutschland
//
//  Bundle resolution and duration for mascot video assets.
//

import AVFoundation
import Foundation

enum VideoBundleLookup {
    /// `Videos` first so the canonical folder name matches API consumers; includes Lid’s on-disk layout.
    static let searchSubdirectories: [String?] = [
        nil,
        "Videos",
        "00 - Core/09 -Resources/Videos",
        "09 -Resources/Videos",
        "04 - Videos",
        "Resources/04 - Videos",
        "09 - Resources/04 - Videos",
        "Core/09 - Resources/04 - Videos"
    ]

    static func url(forResourceName name: String, extension ext: String = "mov") -> URL? {
        searchSubdirectories.lazy.compactMap { subdirectory in
            Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdirectory)
        }.first
    }

    static func resourceExists(resourceName name: String, extension ext: String = "mov") -> Bool {
        url(forResourceName: name, extension: ext) != nil
    }

    static func duration(forResourceName name: String, extension ext: String = "mov") async -> TimeInterval? {
        guard let url = url(forResourceName: name, extension: ext) else { return nil }
        let asset = AVURLAsset(url: url)
        guard let duration = try? await asset.load(.duration) else { return nil }
        let seconds = CMTimeGetSeconds(duration)
        guard seconds.isFinite, seconds > 0 else { return nil }
        return seconds
    }
}
