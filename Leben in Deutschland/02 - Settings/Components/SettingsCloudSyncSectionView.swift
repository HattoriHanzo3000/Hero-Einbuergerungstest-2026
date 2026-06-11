//
//  SettingsCloudSyncSectionView.swift
//  Leben in Deutschland
//
//  Static iCloud sync information in Settings (no toggle; sync is always on via CloudKit).
//  Created: 09.06.26.
//

import SwiftUI

struct SettingsCloudSyncSectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        Section {
            HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
                SettingsIconView(systemName: "icloud.fill", tint: .blue)
                Text("icloud_sync".localized)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("icloud_sync".localized))
        } header: {
            Text("settings_sync_title".localized)
        } footer: {
            Text("icloud_sync_footer_static".localized)
        }
        .id(languageManager.currentAppLanguage)
    }
}

#Preview("Cloud Sync Section") {
    NavigationStack {
        List {
            SettingsCloudSyncSectionView()
        }
        .listStyle(.insetGrouped)
    }
    .environmentObject(LanguageManager())
}
