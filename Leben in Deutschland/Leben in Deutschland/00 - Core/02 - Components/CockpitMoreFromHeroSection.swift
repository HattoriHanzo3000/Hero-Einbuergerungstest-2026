import SwiftUI
import UIKit

/// B2-style "More from Hero" section for Cockpit.
struct CockpitMoreFromHeroSection: View {
    var body: some View {
        CockpitCard(
            titleIcon: "sparkles",
            title: "cockpit_more_from_hero_subtitle".localized
        ) {
            HStack(alignment: .top, spacing: 12) {
                Group {
                    if UIImage(named: "MascotBaseSmall") != nil {
                        Image("MascotBaseSmall")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("MascotLiDHeader")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 72, height: 72, alignment: .top)
                .accessibilityHidden(true)

                Text("cockpit_more_from_hero_body".localized)
                    .font(.system(.subheadline, design: .default))
                    .italic()
                    .foregroundStyle(Color.accentColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal)
    }
}
