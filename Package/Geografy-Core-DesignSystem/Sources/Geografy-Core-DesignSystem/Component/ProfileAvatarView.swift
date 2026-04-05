import SwiftUI

public struct ProfileAvatarView: View {
    // MARK: - Properties
    public let name: String
    public let size: CGFloat

    // MARK: - Init
    public init(name: String, size: CGFloat) {
        self.name = name
        self.size = size
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)
            Text(initials)
                .font(DesignSystem.Font.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
    }
}

// MARK: - Helpers
private extension ProfileAvatarView {
    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing,
        )
    }
}
