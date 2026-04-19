@testable import Geografy_Feature_Onboarding
import Testing

struct OnboardingFlowTests {
    @Test("Goal titles are non-empty")
    func goalTitlesAreNonEmpty() {
        for goal in OnboardingFlow.Goal.allCases {
            #expect(!goal.title.isEmpty)
            #expect(!goal.subtitle.isEmpty)
            #expect(!goal.icon.isEmpty)
        }
    }
}
