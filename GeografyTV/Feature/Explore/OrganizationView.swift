import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct OrganizationView: View {
    let organization: Organization

    var body: some View {
        listContent
            .navigationTitle(organization.displayName)
            .onExitCommand { }
    }
}

// MARK: - Subviews
private extension OrganizationView {
    var listContent: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    header
                    description
                }
            }
        }
    }

    var header: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: organization.icon)
                .font(DesignSystem.Font.system(size: 40))
                .foregroundStyle(organization.highlightColor)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(organization.displayName)
                    .font(DesignSystem.Font.system(size: 32, weight: .bold))

                Text(organization.fullName)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(.secondary)
            }
        }
    }

    var description: some View {
        Text(organization.description)
            .font(DesignSystem.Font.system(size: 20))
            .foregroundStyle(.secondary)
    }
}
