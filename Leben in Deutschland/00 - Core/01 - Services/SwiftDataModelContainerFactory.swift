//
//  SwiftDataModelContainerFactory.swift
//  Leben in Deutschland
//
//  Shared ModelContainer setup: CloudKit in production, in-memory for SwiftUI previews.
//  Created: 11.06.26.
//

import Foundation
import SwiftData

enum SwiftDataModelContainerFactory {
    static let schema = Schema([
        QuestionStatisticsRecord.self,
        LearningAnswerRecord.self,
        FavoriteQuestion.self,
        UserProgressProfile.self,
    ])

    /// CloudKit-backed container for the app; in-memory local store for Xcode Previews.
    static func makeSharedContainer() throws -> ModelContainer {
        if isRunningInPreviewOrPlayground {
            return try makePreviewContainer()
        }
        return try makePersistentContainer()
    }

    /// In-memory container for `#Preview` blocks that need SwiftData without launching CloudKit.
    static func makePreviewContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - Private

    private static var isRunningInPreviewOrPlayground: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    private static func makePersistentContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
#if DEBUG
            // Recover from an incompatible on-disk store after schema changes during development.
            try removeDefaultStoreFiles()
            return try ModelContainer(for: schema, configurations: [configuration])
#else
            throw error
#endif
        }
    }

    private static func removeDefaultStoreFiles() throws {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }

        let storeNames = ["default.store", "default.store-shm", "default.store-wal"]
        for name in storeNames {
            let url = appSupport.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        }
    }
}
