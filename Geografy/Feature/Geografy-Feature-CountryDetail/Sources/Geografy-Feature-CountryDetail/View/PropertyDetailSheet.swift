import Geografy_Core_DesignSystem
import SwiftUI

public struct PropertyDetailSheet: View {
    // MARK: - Properties
    public let icon: String
    public let title: String
    public let value: String
    public let supportsMap: Bool
    public var mapButtonTitle: String = "Show on the map"
    public var onShowMap: (() -> Void)?
    public var actionButtonTitle: String?
    public var actionButtonIcon: String?
    public var onAction: (() -> Void)?

    // MARK: - Body
    public var body: some View {
        sheetContent
            .frame(maxWidth: .infinity)
            // Buttons sit the same distance from the sheet's bottom edge as from its sides.
            .ignoresSafeArea(.container, edges: hasButtons ? .bottom : [])
            .presentationDetents([.height(hasButtons ? 360 : 300)])
    }
}

// MARK: - Subviews
private extension PropertyDetailSheet {
    var sheetContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                SheetIconHeader(icon: icon)
                    .padding(.top, DesignSystem.Spacing.lg)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .textCase(.uppercase)
                        .kerning(1.5)

                    Text(value)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                }

                Spacer(minLength: DesignSystem.Spacing.sm)

                buttonsSection
            }
        }
    }

    var hasButtons: Bool {
        supportsMap || actionButtonTitle != nil
    }

    @ViewBuilder
    var buttonsSection: some View {
        if hasButtons {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if supportsMap, let onShowMap {
                    GlassButton(mapButtonTitle, systemImage: "map.fill", fullWidth: true) {
                        onShowMap()
                    }
                }

                if let actionTitle = actionButtonTitle, let onAction {
                    GlassButton(actionTitle, systemImage: actionButtonIcon ?? "arrow.right", fullWidth: true) {
                        onAction()
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Sheet Icon Header
/// The glowing icon that tops the country detail info sheets.
struct SheetIconHeader: View {
    let icon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.2),
                            DesignSystem.Color.accent.opacity(0.0),
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 56
                    )
                )
                .frame(width: 112, height: 112)

            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(DesignSystem.Font.iconXL.weight(.medium))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .accessibilityHidden(true)
    }
}
