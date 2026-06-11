//
//  SettingsFederalStateAlert.swift
//  Leben in Deutschland
//
//  Presents the federal state change confirmation as a native iOS alert.
//

import SwiftUI

struct FederalStateAlertModifier: ViewModifier {
    @ObservedObject var viewModel: SettingsRegionalViewModel
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content.alert(
            "change_state_confirmation_title".localized,
            isPresented: $viewModel.showStateChangeWarning,
            presenting: viewModel
            ) { regionalViewModel in
                Button(role: .cancel) {
                    regionalViewModel.cancelPendingStateChange()
                } label: {
                    Text("change_state_confirmation_cancel".localized)
                }
                Button {
                    regionalViewModel.confirmPendingStateChange()
                } label: {
                    Text("change_state_confirmation_confirm".localized)
                }
            } message: { _ in
                Text("change_state_confirmation_message".localized)
            }
    }
}

extension View {
    @ViewBuilder
    func federalStateAlert(viewModel: SettingsRegionalViewModel?) -> some View {
        if let viewModel {
            modifier(FederalStateAlertModifier(viewModel: viewModel))
        } else {
            self
        }
    }
}


