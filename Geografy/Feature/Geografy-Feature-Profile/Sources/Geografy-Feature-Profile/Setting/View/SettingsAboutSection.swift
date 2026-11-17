import Geografy_Core_DesignSystem
import Geografy_Core_Service
import StoreKit
import SwiftUI

/// Rating and sharing the app, and its privacy policy and terms.
struct SettingsAboutSection: View {
    // MARK: - Properties
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    // MARK: - Body
    var body: some View {
        SettingsGroup("About") {
            rateAppRow
            #if !os(tvOS)
            SettingsDivider()
            shareAppRow
            #endif
            SettingsDivider()
            Link(destination: SettingsURLs.privacy) {
                SettingsExternalRow(
                    icon: "hand.raised.fill",
                    iconColor: DesignSystem.Color.blue,
                    title: "Privacy Policy"
                )
            }
            .buttonStyle(PressButtonStyle())
            SettingsDivider()
            Link(destination: SettingsURLs.terms) {
                SettingsExternalRow(
                    icon: "doc.text.fill",
                    iconColor: DesignSystem.Color.textSecondary,
                    title: "Terms of Service"
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}

// MARK: - Subviews
private extension SettingsAboutSection {
    var rateAppRow: some View {
        Button {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            requestReview()
        } label: {
            SettingsExternalRow(icon: "star.fill", iconColor: DesignSystem.Color.warning, title: "Rate Geografy")
        }
        .buttonStyle(PressButtonStyle())
    }

    #if !os(tvOS)
    var shareAppRow: some View {
        ShareLink(item: SettingsURLs.appStore) {
            SettingsExternalRow(
                icon: "square.and.arrow.up",
                iconColor: DesignSystem.Color.blue,
                title: "Share Geografy"
            )
        }
        .buttonStyle(PressButtonStyle())
    }
    #endif

    func requestReview() {
        #if !os(tvOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        AppStore.requestReview(in: scene)
        #endif
    }
}
