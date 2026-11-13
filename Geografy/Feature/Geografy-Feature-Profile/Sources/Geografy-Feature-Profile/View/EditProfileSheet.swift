import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct EditProfileSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    @Environment(DatabaseManager.self) private var database
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    @State private var displayName: String = ""
    @State private var isSaving = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        formContent
            .screenBackground()
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
            }
            .onAppear {
                displayName = authService.currentProfile?.displayName ?? ""
            }
    }
}

// MARK: - Subviews
private extension EditProfileSheet {
    var formContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                avatarSection
                nameField
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xl)
        }
    }

    var avatarSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ProfileAvatarView(name: displayName.isEmpty ? "E" : displayName, size: 96)
                .geoShadow(.elevated)
            Text("Tap to change photo")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            EyebrowLabel("Display Name")
                .accessibilityHidden(true)
            TextField("Enter your name", text: $displayName)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(DesignSystem.Spacing.sm)
                .background(.ultraThinMaterial, in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium,
                    style: .continuous
                ))
                .overlay {
                    if colorSchemeContrast == .increased {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .strokeBorder(DesignSystem.Color.dividerSubtle)
                    }
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .accessibilityLabel("Display name")
        }
    }

    var saveButton: some View {
        Button("Save") {
            saveProfile()
        }
        .buttonStyle(.plain)
        .fontWeight(.semibold)
        .accessibilityHint("Saves your display name")
        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
    }
}

// MARK: - Helpers
private extension EditProfileSheet {
    func saveProfile() {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSaving = true
        hapticsService.impact(.medium)
        if let profile = authService.currentProfile {
            profile.displayName = trimmed
            try? database.mainContext.save()
        }
        dismiss()
    }
}
