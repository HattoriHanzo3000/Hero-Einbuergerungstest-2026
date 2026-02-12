//
//  SettingsLanguageChangeAlert.swift
//  Leben in Deutschland
//
//  Presents confirmation dialogs when user changes app or translation language.
//

import SwiftUI

struct LanguageChangeAlertModifier: ViewModifier {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    func body(content: Content) -> some View {
        content
            .alert(
                "settings_app_language_change_title".localized,
                isPresented: $viewModel.showAppLanguageChangeWarning
            ) {
                Button {
                    viewModel.cancelPendingAppLanguageChange()
                } label: {
                    Text("settings_language_change_cancel".localized)
                }
                Button {
                    viewModel.confirmPendingAppLanguageChange()
                } label: {
                    Text("settings_language_change_confirm".localized)
                }
            } message: {
                Text("settings_language_change_message".localized)
            }
            .alert(
                "settings_translation_language_change_title".localized,
                isPresented: $viewModel.showTranslationLanguageChangeWarning
            ) {
                Button {
                    viewModel.cancelPendingTranslationLanguageChange()
                } label: {
                    Text("settings_language_change_cancel".localized)
                }
                Button {
                    viewModel.confirmPendingTranslationLanguageChange()
                } label: {
                    Text("settings_language_change_confirm".localized)
                }
            } message: {
                Text("settings_language_change_message".localized)
            }
    }
}

extension View {
    @ViewBuilder
    func languageChangeAlert(viewModel: SettingsRegionalViewModel?) -> some View {
        if let viewModel {
            modifier(LanguageChangeAlertModifier(viewModel: viewModel))
        } else {
            self
        }
    }
}
