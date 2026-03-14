import SwiftUI

// MARK: - Onboarding Screen Container
/// Reusable container for onboarding screens that provides consistent layout structure
struct OnboardingScreenContainer<Content: View>: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    let headerStep: Int
    let headerMessageKey: String
    let headerMessageParameters: [String]?
    let headerSelectedState: String?
    let headerId: AnyHashable?
    let showDialog: Binding<Bool>
    let isNextEnabled: Bool
    let showBackButton: Bool
    let nextButtonTitleKey: String
    let onNext: () -> Void
    let onBack: (() -> Void)?
    let onSetup: () -> Void
    @ObservedObject var languageManager: LanguageManager
    let contentPadding: EdgeInsets?
    let disableContentAnimation: Bool
    @ViewBuilder let content: Content
    
    @State private var nextPlayToken: UUID? = nil
    
    init(
        headerStep: Int,
        headerMessageKey: String,
        headerMessageParameters: [String]? = nil,
        headerSelectedState: String? = nil,
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
        self.headerSelectedState = headerSelectedState
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
                    selectedState: headerSelectedState,
                    showDialog: showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: onNext
                )
                .id(headerId)
                .padding(.top, OnboardingConstants.headerTopPadding)
                .padding(.bottom, layoutMetrics.adaptive(12))
                
                Divider()
                    .background(Color(.separator))
                
                // Scrollable content block
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
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
                        .padding(.top, OnboardingConstants.contentVerticalPadding)
                        .padding(.bottom, OnboardingConstants.contentVerticalPadding)
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity, alignment: .top)
                .scrollDismissesKeyboard(.interactively)
                
                Divider()
                    .background(Color(.separator))
                
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

