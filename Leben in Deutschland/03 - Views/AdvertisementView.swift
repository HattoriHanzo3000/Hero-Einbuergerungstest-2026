import AVFoundation
import SwiftUI

// MARK: - Screen
struct AdvertisementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var b2ArtworkURL: URL?
    @State private var artworkLookupFinished = false
    @State private var b2TrackName: String?
    @State private var b2Subtitle: String?
    @State private var flagPlayer: AVPlayer?
    @State private var flagEndObserver: NSObjectProtocol?
    @State private var flagReplayTask: Task<Void, Never>?
    @State private var flagPlayerAssetName: String?

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassGradient.blue.screenBackground
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .center, spacing: 10) {
                            Text("advertisement_hero_lead_title".localized)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .italic()
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            flagAnimationView
                                .frame(width: 200, height: 200)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)

                            Text("advertisement_hero_lead_subtitle".localized)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.88))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)

                        b2AppRow
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .background(Color.clear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                    .accessibilityLabel("paywall_close".localized)
                    .accessibilityHint("paywall_close_hint".localized)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            prepareFlagPlayerIfNeeded()
        }
        .onDisappear {
            cleanupFlagPlayer()
        }
        .task {
            let appSummary = await AppStoreArtworkLookup.lookupApp(
                appID: AdvertisementDestination.b2AppStoreID,
                appStoreURL: AdvertisementDestination.b2AppStoreURL
            )
            b2ArtworkURL = appSummary?.artworkURL
            b2TrackName = appSummary?.trackName
            b2Subtitle = appSummary?.subtitle
            artworkLookupFinished = true
        }
    }

    private var b2AppRow: some View {
        Button {
            HeroB2StorePresentation.present()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                B2AppIconView(
                    artworkURL: b2ArtworkURL,
                    lookupFinished: artworkLookupFinished
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(b2TrackName ?? "")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    Text(b2Subtitle ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(
            "\(b2TrackName ?? ""). \(b2Subtitle ?? "")"
        )
    }

    private var flagAnimationView: some View {
        Group {
            if let flagPlayer {
                AlphaVideoPlayerView(player: flagPlayer, videoGravity: .resizeAspect)
                    .id(flagVideoAssetName)
                    .allowsHitTesting(false)
                    .onAppear {
                        flagPlayer.play()
                    }
            } else {
                Image("MascotLiDHeader")
                    .resizable()
                    .scaledToFit()
                    .allowsHitTesting(false)
            }
        }
    }

    private var flagVideoAssetName: String {
        "MascotFlag"
    }

    private var flagVideoURL: URL? {
        Bundle.main.url(forResource: flagVideoAssetName, withExtension: "mov")
            ?? Bundle.main.url(forResource: flagVideoAssetName, withExtension: "mp4")
    }

    private func prepareFlagPlayerIfNeeded() {
        guard let url = flagVideoURL else {
            cleanupFlagPlayer()
            return
        }

        if flagPlayerAssetName == flagVideoAssetName, flagPlayer != nil {
            flagPlayer?.play()
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = true

        if let flagEndObserver {
            NotificationCenter.default.removeObserver(flagEndObserver)
            self.flagEndObserver = nil
        }

        flagEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            scheduleFlagReplay(for: player)
        }

        flagPlayer = player
        flagPlayerAssetName = flagVideoAssetName
        player.play()
    }

    private func scheduleFlagReplay(for player: AVPlayer?) {
        flagReplayTask?.cancel()
        flagReplayTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled, let player else { return }
                await player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                player.play()
            } catch {
                // Cancellation is expected when the sheet disappears.
            }
        }
    }

    private func cleanupFlagPlayer() {
        flagReplayTask?.cancel()
        flagReplayTask = nil

        if let flagEndObserver {
            NotificationCenter.default.removeObserver(flagEndObserver)
            self.flagEndObserver = nil
        }

        flagPlayer?.pause()
        flagPlayer?.replaceCurrentItem(with: nil)
        flagPlayer = nil
        flagPlayerAssetName = nil
    }
}

// MARK: - Destination
private enum AdvertisementDestination {
    static let b2AppStoreID = 6755700752
    static let b2AppStoreURL = URL(string: "https://apps.apple.com/us/app/hero-b2-beruf-vokabeln/id6755700752")!
}

// MARK: - App Icon View
private struct B2AppIconView: View {
    let artworkURL: URL?
    let lookupFinished: Bool

    private let size: CGFloat = 60
    private let cornerRadius: CGFloat = 13

    var body: some View {
        Group {
            if !lookupFinished {
                ProgressView()
                    .tint(.white.opacity(0.9))
                    .frame(width: size, height: size)
            } else if let artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white.opacity(0.9))
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.white.opacity(0.14)
                    @unknown default:
                        Color.white.opacity(0.14)
                    }
                }
            } else {
                Color.white.opacity(0.14)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .accessibilityHidden(true)
    }
}

// MARK: - iTunes Lookup Models
private struct ITunesLookupResponse: Decodable {
    let results: [ITunesLookupAppResult]
}

private struct ITunesLookupAppResult: Decodable {
    let artworkUrl60: String?
    let artworkUrl100: String?
    let artworkUrl512: String?
    let trackName: String?
    let subtitle: String?
}

private enum AppStoreArtworkLookup {
    struct AppSummary {
        let artworkURL: URL?
        let trackName: String?
        let subtitle: String?
    }

    static func lookupApp(appID: Int, appStoreURL: URL, countryCode: String = "us") async -> AppSummary? {
        var components = URLComponents(url: URL(string: "https://itunes.apple.com/lookup")!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "id", value: String(appID)),
            URLQueryItem(name: "country", value: countryCode)
        ]
        guard let url = components.url else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                return nil
            }
            let decoded = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
            guard let first = decoded.results.first else { return nil }
            let string = first.artworkUrl512 ?? first.artworkUrl100 ?? first.artworkUrl60
            let artworkURL = string.flatMap { URL(string: $0) }

            let normalizedSubtitle = first.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
            let subtitle = if normalizedSubtitle?.isEmpty == false {
                normalizedSubtitle
            } else {
                await fetchSubtitle(from: appStoreURL)
            }

            return AppSummary(
                artworkURL: artworkURL,
                trackName: first.trackName,
                subtitle: subtitle
            )
        } catch {
            return nil
        }
    }

    private static func fetchSubtitle(from url: URL) async -> String? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode),
                  let html = String(data: data, encoding: .utf8) else {
                return nil
            }
            return extractSubtitle(from: html)
        } catch {
            return nil
        }
    }

    private static func extractSubtitle(from html: String) -> String? {
        let pattern = #"<p class="subtitle[^"]*">([^<]+)</p>"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }

        let subtitle = html[range]
            .htmlDecoded()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return subtitle.isEmpty ? nil : subtitle
    }
}

private extension StringProtocol {
    func htmlDecoded() -> String {
        String(self)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

#Preview {
    AdvertisementView()
}
