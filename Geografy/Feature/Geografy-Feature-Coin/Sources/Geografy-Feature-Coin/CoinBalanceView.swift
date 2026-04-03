import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CoinBalanceView: View {
    @Environment(CoinService.self) private var coinService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var displayedBalance = 0
    @State private var glowScale: CGFloat = 1.0

    public var body: some View {
        mainContent
            .onAppear {
                displayedBalance = coinService.balance
                startGlowAnimation()
            }
            .onChange(of: coinService.balance) { _, newValue in
                animateBalanceChange(to: newValue)
            }
    }
}

// MARK: - Subviews
private extension CoinBalanceView {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            coinIcon
            balanceLabel
            subtitle
        }
    }

    var coinIcon: some View {
        ZStack {
            coinGlowCircle
            coinSymbol
        }
    }

    var coinGlowCircle: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        DesignSystem.Color.warning.opacity(0.4),
                        DesignSystem.Color.warning.opacity(0.0),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: DesignSystem.Size.xxxl
                )
            )
            .frame(
                width: 120,
                height: 120
            )
            .scaleEffect(glowScale)
    }

    var coinSymbol: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        DesignSystem.Color.warning,
                        DesignSystem.Color.orange,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(
                color: DesignSystem.Color.warning.opacity(0.5),
                radius: DesignSystem.Spacing.sm,
                y: DesignSystem.Spacing.xxs
            )
    }

    var balanceLabel: some View {
        Text(formattedDisplayBalance)
            .font(DesignSystem.Font.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .contentTransition(.numericText())
    }

    var subtitle: some View {
        Text("Your Coins")
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }
}

// MARK: - Helpers
private extension CoinBalanceView {
    var formattedDisplayBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: displayedBalance)) ?? "\(displayedBalance)"
    }

    func startGlowAnimation() {
        guard !reduceMotion else { glowScale = 1.15; return }
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            glowScale = 1.15
        }
    }

    func animateBalanceChange(to newValue: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            displayedBalance = newValue
        }
    }
}
