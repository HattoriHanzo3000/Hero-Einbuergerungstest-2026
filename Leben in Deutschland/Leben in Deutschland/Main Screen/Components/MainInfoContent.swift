//
//  MainInfoContent.swift
//  Leben in Deutschland
//
//  Main info content section with federal state, statistics, and mascot
//

import SwiftUI

// MARK: - Main Info Content
struct MainInfoContent: View {
    @EnvironmentObject var stateManager: StateManager
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var showDialog: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Federal State Section
            FederalStateSection()
            
            // Statistics Section (placeholder)
            MainStatisticsSection()
            
            // Mascot Section
            MascotSection(showDialog: $showDialog)
        }
    }
}

// MARK: - Federal State Section
struct FederalStateSection: View {
    @EnvironmentObject var stateManager: StateManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            
            // Federal State name and slogan (on left, aligned right)
            VStack(alignment: .trailing, spacing: 4) {
                // Federal State name (localized)
                Text((stateManager.selectedState ?? "Berlin").localized)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.trailing)
                
                // Federal State slogan (localized)
                Text(getStateSloganKey(stateManager.selectedState ?? "Berlin"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.trailing)
            }
            .id(languageManager.currentAppLanguage)
            
            // 60x60 square on the right
            Rectangle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color("AppBackground"))
        .border(Color.red, width: 2)
    }
    
    private func getStateSloganKey(_ stateName: String) -> String {
        let normalized = stateName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        let key = "state_\(normalized)"
        return key.localized
    }
}

// MARK: - Main Statistics Section
struct MainStatisticsSection: View {
    var body: some View {
        HStack {
            Spacer()
            
            // Green circle (centered)
            Circle()
                .fill(Color.green)
                .frame(width: 300, height: 300)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color("AppBackground"))
        .border(Color.orange, width: 2)
    }
}

// MARK: - Mascot Section
struct MascotSection: View {
    @Binding var showDialog: Bool
    @EnvironmentObject var stateManager: StateManager
    
    private var savedTestDate: Date? {
        return UserDefaults.standard.object(forKey: "selectedTestDate") as? Date
    }
    
    private var daysUntilTest: Int? {
        guard let testDate = savedTestDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let testDateStart = calendar.startOfDay(for: testDate)
        let days = calendar.dateComponents([.day], from: today, to: testDateStart).day ?? 0
        return days > 0 ? days : nil
    }
    
    var body: some View {
        VStack {
            MascotWithTwoPartMessage(
                showDialog: $showDialog,
                daysUntilTest: daysUntilTest
            )
            .frame(height: 150)  // Fixed height for GeometryReader
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 30)
        .background(Color("AppBackground"))
        .border(Color.purple, width: 2)
    }
}

// MARK: - Mascot With Two Part Message
struct MascotWithTwoPartMessage: View {
    @Binding var showDialog: Bool
    let daysUntilTest: Int?
    
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @EnvironmentObject var languageManager: LanguageManager
    
    private var twoPartMessage: String {
        var message = ""
        
        // Part 1: Test date message (if date is set)
        if let days = daysUntilTest {
            let testMessage = getTestDateMessage(days: days)
            message += testMessage + "\n\n"
        }
        
        // Part 2: Progress-based message (placeholder for now)
        message += "welcome_message".localized
        
        return message
    }
    
    private func getTestDateMessage(days: Int) -> String {
        let appLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        switch appLanguage {
        case "de":
            let dayWord = days == 1 ? "Tag" : "Tage"
            return "Der Test ist in \(days) \(dayWord)"
        case "ru":
            let dayWord = getDayWord(for: days, language: "ru")
            return "До теста \(days) \(dayWord)"
        case "uk":
            let dayWord = getDayWord(for: days, language: "uk")
            return "До тесту \(days) \(dayWord)"
        default: // en
            let dayWord = days == 1 ? "day" : "days"
            return "The test is in \(days) \(dayWord)"
        }
    }
    
    private func getDayWord(for days: Int, language: String) -> String {
        switch language {
        case "ru":
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "дней"
            }
            switch lastDigit {
            case 1: return "день"
            case 2, 3, 4: return "дня"
            default: return "дней"
            }
        case "uk":
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "днів"
            }
            switch lastDigit {
            case 1: return "день"
            case 2, 3, 4: return "дні"
            default: return "днів"
            }
        default:
            return "days"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let sidePadding: CGFloat = 8
            let bubbleWidth = geometry.size.width - 140
            let mascotSize = MainScreenConstants.getEmojiSize()
            let spacing = MainScreenConstants.mascotBubbleSpacing
            
            HStack(alignment: .center, spacing: spacing) {
                // Mascot
                ZStack {
                    if showMascotGif {
                        let gifName = UITraitCollection.current.userInterfaceStyle == .dark ? "MainChickDark" : "MainChick"
                        if let _ = Bundle.main.url(forResource: gifName, withExtension: "gif") {
                            AnimatedGIFView(gifName: gifName)
                                .id(gifPlayToken)
                                .frame(width: mascotSize, height: mascotSize)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    } else if UIImage(named: "MainChick") != nil {
                        Image("MainChick")
                            .resizable()
                            .scaledToFit()
                            .frame(width: mascotSize, height: mascotSize)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(width: mascotSize, height: mascotSize)
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    showMascotGif = true
                    gifPlayToken = UUID()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showMascotGif = false
                    }
                }
                
                // Dialog bubble
                if showDialog {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(twoPartMessage)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                            .id(languageManager.currentAppLanguage)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(width: bubbleWidth)
                    .offset(x: 10)
                    .background(
                        DialogBubbleShape()
                            .fill(Color(.systemGray6))
                            .overlay(
                                DialogBubbleShape()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, sidePadding)
            .padding(.trailing, sidePadding)
        }
    }
}

// MARK: - Preview
#Preview {
    MainInfoContent(showDialog: .constant(true))
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
}

