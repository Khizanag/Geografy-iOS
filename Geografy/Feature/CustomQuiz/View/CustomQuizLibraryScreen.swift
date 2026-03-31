import SwiftUI
import GeografyDesign

struct CustomQuizLibraryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quizService = CustomQuizService()

    @State private var showBuilder = false
    @State private var editingQuiz: CustomQuiz?
    @State private var shareableQuiz: CustomQuiz?
    @State private var quizToDelete: CustomQuiz?
    @State private var countryDataService = CountryDataService()

    var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle("My Quizzes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showBuilder) { builderSheet }
            .sheet(item: $editingQuiz) { quiz in editSheet(for: quiz) }
            .sheet(item: $shareableQuiz) { quiz in shareSheet(for: quiz) }
            .alert("Delete Quiz?", isPresented: deleteAlertBinding) { deleteAlertActions }
            .task { countryDataService.loadCountries() }
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
                shareableQuiz = quiz
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
        ToolbarItem(placement: .topBarTrailing) {
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

    func shareSheet(for quiz: CustomQuiz) -> some View {
        NavigationStack {
            ScrollView {
                Text(quiz.shareableJSON)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignSystem.Color.cardBackground)
                    .clipShape(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    )
                    .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Color.background)
            .navigationTitle("Share Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        UIPasteboard.general.string = quiz.shareableJSON
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton { shareableQuiz = nil }
                }
            }
        }
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
