import SwiftUI
import GeografyDesign

struct EditProfileSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(DatabaseManager.self) private var database
    @Environment(HapticsService.self) private var hapticsService

    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var isSaving = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            formContent
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
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
                .shadow(color: DesignSystem.Color.accent.opacity(0.35), radius: 16, x: 0, y: 4)
            Text("Tap to change photo")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Display Name")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .textCase(.uppercase)
                .kerning(0.8)
            TextField("Enter your name", text: $displayName)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(DesignSystem.Spacing.sm)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
    }

    var cancelButton: some View {
        Button("Cancel") { dismiss() }
            .buttonStyle(.plain)
    }

    var saveButton: some View {
        Button("Save") {
            saveProfile()
        }
        .buttonStyle(.plain)
        .fontWeight(.semibold)
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
