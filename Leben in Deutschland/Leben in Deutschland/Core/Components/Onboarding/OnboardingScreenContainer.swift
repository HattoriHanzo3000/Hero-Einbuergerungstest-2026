import SwiftUI

// MARK: - Onboarding Screen Container
/// Reusable container for onboarding screens that provides consistent layout structure
struct OnboardingScreenContainer<Content: View>: View {
    let headerStep: Int
    let headerMessageKey: String
    let headerMessageParameters: [String]?
    let headerId: AnyHashable?
    let showDialog: Binding<Bool>
    let isNextEnabled: Bool
    let showBackButton: Bool
    let nextButtonTitleKey: String
    let onNext: () -> Void
    let onBack: (() -> Void)?
    let onSetup: () -> Void
    let languageManager: LanguageManager
    let contentPadding: EdgeInsets?
    let disableContentAnimation: Bool
    @ViewBuilder let content: Content
    
    @State private var nextPlayToken: UUID? = nil
    
    init(
        headerStep: Int,
        headerMessageKey: String,
        headerMessageParameters: [String]? = nil,
        headerId: AnyHashable? = nil,
        showDialog: Binding<Bool>,
        isNextEnabled: Bool,
        showBackButton: Bool = false,
        nextButtonTitleKey: String = "NEXT",
        onNext: @escaping () -> Void,
        onBack: (() -> Void)? = nil,
        onSetup: @escaping () -> Void,
        languageManager: LanguageManager,
        contentPadding: EdgeInsets? = nil,
        disableContentAnimation: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.headerStep = headerStep
        self.headerMessageKey = headerMessageKey
        self.headerMessageParameters = headerMessageParameters
        self.headerId = headerId
        self.showDialog = showDialog
        self.isNextEnabled = isNextEnabled
        self.showBackButton = showBackButton
        self.nextButtonTitleKey = nextButtonTitleKey
        self.onNext = onNext
        self.onBack = onBack
        self.onSetup = onSetup
        self.languageManager = languageManager
        self.contentPadding = contentPadding
        self.disableContentAnimation = disableContentAnimation
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header island with progress and mascot
                OnboardingHeaderComponent(
                    currentStep: headerStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    messageKey: headerMessageKey,
                    messageParameters: headerMessageParameters,
                    showDialog: showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: onNext
                )
                .id(headerId)
                .padding(.top, OnboardingConstants.headerTopPadding)
                
                // Content
                Group {
                    if disableContentAnimation {
                        content
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                    } else {
                        content
                    }
                }
                .applyPadding(contentPadding)
                
                Spacer()
                
                // Next Button
                OnboardingNextButtonComponent(
                    isEnabled: isNextEnabled,
                    action: { nextPlayToken = UUID() },
                    showBackButton: showBackButton,
                    backAction: onBack,
                    titleKey: nextButtonTitleKey
                )
            }
        }
        .onAppear {
            onSetup()
        }
        .environmentObject(languageManager)
    }
}

// MARK: - View Extension Helper
private extension View {
    @ViewBuilder
    func applyPadding(_ padding: EdgeInsets?) -> some View {
        if let padding = padding {
            self.padding(padding)
        } else {
            self
        }
    }
}

