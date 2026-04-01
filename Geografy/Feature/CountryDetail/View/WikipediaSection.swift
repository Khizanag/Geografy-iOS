#if !os(tvOS)
import GeografyDesign
import SwiftUI

struct WikipediaSection: View {
    private let countryName: String

    @State private var showSafari = false

    init(countryName: String) {
        self.countryName = countryName
    }

    var body: some View {
        Button {
            showSafari = true
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    iconView

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("Read on Wikipedia")
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text("Learn more about \(countryName)")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.up.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .sheet(isPresented: $showSafari) {
            if let url = wikipediaURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Subviews
private extension WikipediaSection {
    var iconView: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.textSecondary.opacity(0.12))
                .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
            Text("W")
                .font(DesignSystem.Font.serifBody)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Helpers
private extension WikipediaSection {
    var wikipediaURL: URL? {
        let encodedName = countryName
            .replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? countryName
        return URL(string: "https://en.wikipedia.org/wiki/\(encodedName)")
    }
}
#endif
