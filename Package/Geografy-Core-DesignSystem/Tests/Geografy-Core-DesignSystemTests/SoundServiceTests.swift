@testable import Geografy_Core_DesignSystem
import Testing

@Suite("SoundService")
struct SoundServiceTests {
    @Test("Every sound effect ships a sound file", arguments: SoundEffect.allCases)
    func soundFileExists(effect: SoundEffect) {
        #expect(SoundService.url(for: effect) != nil)
    }
}
