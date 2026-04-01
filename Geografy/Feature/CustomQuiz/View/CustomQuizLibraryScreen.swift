import GeografyDesign
import SwiftUI

struct CustomQuizLibraryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    @State private var quizService = CustomQuizService()
    @State private var showBuilder = false
    @State private var editingQuiz: CustomQuiz?
    @State private var quizToDelete: CustomQuiz?

    var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle("My Quizzes")
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .sheet(isPresented: $showBuilder) { builderSheet }
            .sheet(item: $editingQuiz) { quiz in editSheet(for: quiz) }
            .alert("Delete Quiz?", isPresented: deleteAlertBinding) { deleteAlertActions }
    }
}

// MARK: - Content
private extension CustomQuizLibraryScreen {
    @ViewBuilder
    var content: some View {
        if quizService.quizzes.isEmpty {
            emptyState
        } else {
            quizList
        }
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label("No Custom Quizzes", systemImage: "plus.square.dashed")
        } description: {
            Text("Create your own geography quiz by selecting countries and question types.")
        } actions: {
            Button("Create Quiz") { showBuilder = true }
                .buttonStyle(.borderedProminent)
        }
    }

    var quizList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(quizService.quizzes) { quiz in
                    quizRow(quiz)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Quiz Row
private extension CustomQuizLibraryScreen {
    func quizRow(_ quiz: CustomQuiz) -> some View {
        CustomQuizCard(quiz: quiz)
            .contextMenu { contextMenuItems(for: quiz) }
            .buttonStyle(PressButtonStyle())
    }

    func contextMenuItems(for quiz: CustomQuiz) -> some View {
        Group {
            Button {
                editingQuiz = quiz
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                coordinator.sheet(.customQuizShare(quiz))
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button(role: .destructive) {
                quizToDelete = quiz
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Toolbar
private extension CustomQuizLibraryScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showBuilder = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Sheets
private extension CustomQuizLibraryScreen {
    var builderSheet: some View {
        CustomQuizBuilderScreen(
            countryDataService: countryDataService,
            quizService: quizService
        )
    }

    func editSheet(for quiz: CustomQuiz) -> some View {
        CustomQuizBuilderScreen(
            existingQuiz: quiz,
            countryDataService: countryDataService,
            quizService: quizService
        )
    }
}

// MARK: - Delete Alert
private extension CustomQuizLibraryScreen {
    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { quizToDelete != nil },
            set: { if !$0 { quizToDelete = nil } },
        )
    }

    @ViewBuilder
    var deleteAlertActions: some View {
        Button("Cancel", role: .cancel) {
            quizToDelete = nil
        }
        Button("Delete", role: .destructive) {
            if let quiz = quizToDelete {
                withAnimation { quizService.delete(quiz) }
            }
            quizToDelete = nil
        }
    }
}
