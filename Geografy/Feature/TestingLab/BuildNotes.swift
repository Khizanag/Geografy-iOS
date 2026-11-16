#if DEBUG
import Geografy_Core_DesignSystem
import SwiftUI

/// One change in this build: what to look at, how to try it, and where it is.
struct BuildNote: Identifiable {
    /// Where trying the change starts.
    enum Target {
        case screen(HubItem)
        case tab(AppTab)
        case levelUp
    }

    let commit: String
    let title: LocalizedStringResource
    let howToTest: LocalizedStringResource
    let systemImage: String
    let color: Color
    let target: Target?
    /// Turned on before going to the target, for changes only Testing Mode shows.
    var needsTestingMode = false

    var id: String { commit }
}

// MARK: - This Build
/// The changes to try in this build, newest first. Rewritten with every build handed over for testing, so it lists
/// only what that build adds.
enum BuildNotes {
    static let current: [BuildNote] = [
        BuildNote(
            commit: "78acbcdb",
            title: "Test badges on hub tiles",
            howToTest: """
                Each tile has an orange glass bubble half over its corner, on top of the glass. Tap one: \
                that screen's checklist opens.
                """,
            systemImage: "ladybug.fill",
            color: DesignSystem.Color.orange,
            target: .tab(.profile),
            needsTestingMode: true
        ),
        BuildNote(
            commit: "f928b173",
            title: "Test checklist sheet",
            howToTest: """
                Tick checks: the count and bar update, and turn green when all pass. Close and reopen: \
                ticks stay. Open goes to the screen; Uncheck All clears.
                """,
            systemImage: "checklist",
            color: DesignSystem.Color.blue,
            target: .tab(.profile),
            needsTestingMode: true
        ),
        BuildNote(
            commit: "ac42a0f1",
            title: "Red Remove in menus",
            howToTest: """
                Pick two countries, then long-press one: Remove's icon and label are both red. \
                Same on a recent search chip.
                """,
            systemImage: "arrow.left.arrow.right",
            color: DesignSystem.Color.blue,
            target: .screen(.compare)
        ),
        BuildNote(
            commit: "479ea4f4",
            title: "Testing Lab",
            howToTest: "Shake the phone to open it. Rows have Settings-style icons, and every reset row is red.",
            systemImage: "flask.fill",
            color: DesignSystem.Color.orange,
            target: nil
        ),
        BuildNote(
            commit: "f7e97b2a",
            title: "Level-up celebration",
            howToTest: """
                A glass card with the tier badge, the level's title, and progress to the next level. \
                In Dark Mode the screen behind darkens.
                """,
            systemImage: "sparkles",
            color: DesignSystem.Color.indigo,
            target: .levelUp
        ),
        BuildNote(
            commit: "a07891b0",
            title: "Quiz type tiles",
            howToTest: "Every type's name fits, with no extra space before Flag Quiz's icon.",
            systemImage: "square.grid.2x2.fill",
            color: DesignSystem.Color.purple,
            target: .screen(.quiz)
        ),
        BuildNote(
            commit: "a78a6c5d",
            title: "Saved map",
            howToTest: """
                The map opens without a wait from the second launch on. Clear Saved Map below, relaunch: \
                the first open is slower again.
                """,
            systemImage: "map.fill",
            color: DesignSystem.Color.blue,
            target: .tab(.map)
        ),
    ]
}

// MARK: - Section
/// The lab's list of this build's changes; tapping one goes where it is.
struct BuildNotesSection: View {
    let notes: [BuildNote]
    let onGo: (BuildNote) -> Void

    var body: some View {
        Section {
            ForEach(notes) { note in
                if note.target == nil {
                    row(note)
                } else {
                    Button { onGo(note) } label: { row(note) }
                        .accessibilityHint("Goes where this change is")
                }
            }
        } header: {
            Text("In This Build")
        } footer: {
            Text("What changed since the last build, and how to try it. Tap a change to go where it is.")
        }
    }

    private func row(_ note: BuildNote) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: note.systemImage, color: note.color)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(note.title)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(note.howToTest)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(verbatim: note.commit)
                    .font(DesignSystem.Font.caption.monospaced())
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
            if note.target != nil {
                Image(systemName: "arrow.up.forward")
                    .font(DesignSystem.Font.caption.weight(.semibold))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }
}
#endif
