import Geografy_Core_Common
import Geografy_Core_Navigation
import SwiftUI

/// Screens only the Profile feature opens.
enum ProfileLocalRoute: Route {
    case achievementDetail(AchievementDefinition)
    case editProfile
    case signIn
    case storage
    case territorialDisputes
}

public extension RouteRegistry {
    /// Registers the screens of the Profile feature's routes.
    mutating func registerProfileScreens() {
        register(ProfileRoute.self) { route in
            switch route {
            case .achievements: AchievementsScreen()
            case .leaderboards: LeaderboardScreen()
            case .profile: ProfileScreen()
            case .settings: SettingsScreen()
            }
        }
        register(ProfileLocalRoute.self) { route in
            switch route {
            case .achievementDetail(let definition): AchievementDetailView(definition: definition)
            case .editProfile: EditProfileSheet()
            case .signIn: SignInOptionsSheet()
            case .storage: StorageScreen()
            case .territorialDisputes: TerritorialDisputesScreen()
            }
        }
    }
}
