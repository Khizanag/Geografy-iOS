import Foundation

struct CoinPack: Identifiable {
    let id: String
    let coins: Int
    let price: String
    let priceValue: Double
    let bonusPercentage: Int
    let isPopular: Bool
    let isBestValue: Bool
    let badgeIcon: String
}

// MARK: - Available Packs

extension CoinPack {
    static let allPacks: [CoinPack] = [
        CoinPack(
            id: "com.khizanag.geografy.coins.100",
            coins: 100,
            price: "$0.99",
            priceValue: 0.99,
            bonusPercentage: 0,
            isPopular: false,
            isBestValue: false,
            badgeIcon: ""
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.500",
            coins: 500,
            price: "$3.99",
            priceValue: 3.99,
            bonusPercentage: 25,
            isPopular: false,
            isBestValue: false,
            badgeIcon: "plus.circle.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.1200",
            coins: 1_200,
            price: "$7.99",
            priceValue: 7.99,
            bonusPercentage: 50,
            isPopular: true,
            isBestValue: false,
            badgeIcon: "star.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.3000",
            coins: 3_000,
            price: "$14.99",
            priceValue: 14.99,
            bonusPercentage: 100,
            isPopular: false,
            isBestValue: true,
            badgeIcon: "bolt.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.7500",
            coins: 7_500,
            price: "$29.99",
            priceValue: 29.99,
            bonusPercentage: 150,
            isPopular: false,
            isBestValue: false,
            badgeIcon: "flame.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.20000",
            coins: 20_000,
            price: "$49.99",
            priceValue: 49.99,
            bonusPercentage: 200,
            isPopular: false,
            isBestValue: false,
            badgeIcon: "crown.fill"
        ),
    ]
}

// MARK: - Helpers

extension CoinPack {
    var formattedCoins: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: coins)) ?? "\(coins)"
    }

    var coinsPerDollar: Int {
        guard priceValue > 0 else { return 0 }
        return Int(Double(coins) / priceValue)
    }

    var tagText: String? {
        if isPopular {
            "Popular"
        } else if isBestValue {
            "Best Value"
        } else if bonusPercentage > 0 {
            "+\(bonusPercentage)% Bonus"
        } else {
            nil
        }
    }

    var detailDescription: String {
        if isBestValue {
            "Our best value pack — maximize your coin collection with the highest bonus rate."
        } else if isPopular {
            "The most popular choice among explorers. Great balance of value and coins."
        } else if bonusPercentage >= 150 {
            "A massive coin haul for the most dedicated geography enthusiasts."
        } else if bonusPercentage >= 100 {
            "Double your coins! Perfect for unlocking premium content faster."
        } else if bonusPercentage > 0 {
            "Get extra bonus coins on top of your purchase."
        } else {
            "A starter pack to get you going on your geography journey."
        }
    }
}
