import Geografy_Core_Navigation
#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CustomQuizLibraryScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    @State private var quizService = CustomQuizService()
    @State private var showBuilder = false
    @State private var editingQuiz: CustomQuiz?
    @State private var quizToDelete: CustomQuiz?
    @State private var selectedQuiz: CustomQuiz?

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle("My Quizzes")
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .sheet(isPresented: $showBuilder) { builderSheet }
            .sheet(item: $editingQuiz) { quiz in editSheet(for: quiz) }
            .sheet(item: $selectedQuiz) { quiz in detailSheet(for: quiz) }
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
            GlassButton("Create Quiz", systemImage: "plus") {
                showBuilder = true
            }
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
        Button {
            selectedQuiz = quiz
        } label: {
            CustomQuizCard(quiz: quiz)
        }
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
                Label("Add", systemImage: "plus")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
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

    func detailSheet(for quiz: CustomQuiz) -> some View {
        CustomQuizDetailSheet(
            quiz: quiz,
            onEdit: {
                selectedQuiz = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    editingQuiz = quiz
                }
            },
            onPlay: {
                selectedQuiz = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    let config = QuizConfiguration(
                        type: quiz.questionTypes.first ?? .flagQuiz,
                        region: .world,
                        difficulty: .medium,
                        questionCount: .fifteen,
                        answerMode: .multipleChoice,
                        comparisonMetric: .population,
                        gameMode: .classic,
                    )
                    coordinator.push(.quizSession(config))
                }
            },
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
#endif
