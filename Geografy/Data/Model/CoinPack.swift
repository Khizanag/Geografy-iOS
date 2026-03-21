import Foundation

struct CoinPack: Identifiable {
    let id: String
    let coins: Int
    let price: String
    let priceValue: Double
    let bonusPercentage: Int
    let isPopular: Bool
    let isBestValue: Bool
    let icon: String
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
            icon: "circle.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.500",
            coins: 500,
            price: "$3.99",
            priceValue: 3.99,
            bonusPercentage: 25,
            isPopular: false,
            isBestValue: false,
            icon: "circle.circle.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.1200",
            coins: 1_200,
            price: "$7.99",
            priceValue: 7.99,
            bonusPercentage: 50,
            isPopular: true,
            isBestValue: false,
            icon: "star.circle.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.3000",
            coins: 3_000,
            price: "$14.99",
            priceValue: 14.99,
            bonusPercentage: 100,
            isPopular: false,
            isBestValue: true,
            icon: "shield.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.7500",
            coins: 7_500,
            price: "$29.99",
            priceValue: 29.99,
            bonusPercentage: 150,
            isPopular: false,
            isBestValue: false,
            icon: "bolt.circle.fill"
        ),
        CoinPack(
            id: "com.khizanag.geografy.coins.20000",
            coins: 20_000,
            price: "$49.99",
            priceValue: 49.99,
            bonusPercentage: 200,
            isPopular: false,
            isBestValue: false,
            icon: "crown.fill"
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
}
