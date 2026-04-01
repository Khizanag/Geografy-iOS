import Foundation

public final class OceanService {
    public init() {}
    public let oceans: [Ocean] = [
        Ocean(
            id: "pacific",
            name: "Pacific Ocean",
            area: 165_250_000,
            averageDepth: 4_280,
            maxDepth: 11_034,
            borderingContinents: ["Asia", "Australia", "North America", "South America", "Antarctica"],
            funFact: "The Pacific Ocean is so large that all of Earth's continents could fit inside it.",
            icon: "water.waves",
            isOcean: true
        ),
        Ocean(
            id: "atlantic",
            name: "Atlantic Ocean",
            area: 106_460_000,
            averageDepth: 3_332,
            maxDepth: 8_376,
            borderingContinents: ["North America", "South America", "Europe", "Africa", "Antarctica"],
            funFact: "The Atlantic Ocean is widening by about 2.5 cm per year as tectonic plates diverge.",
            icon: "water.waves",
            isOcean: true
        ),
        Ocean(
            id: "indian",
            name: "Indian Ocean",
            area: 70_560_000,
            averageDepth: 3_741,
            maxDepth: 7_258,
            borderingContinents: ["Africa", "Asia", "Australia", "Antarctica"],
            funFact: "The Indian Ocean has the warmest waters of all oceans, with surface temps above 22°C.",
            icon: "water.waves",
            isOcean: true
        ),
        Ocean(
            id: "arctic",
            name: "Arctic Ocean",
            area: 14_056_000,
            averageDepth: 1_205,
            maxDepth: 5_527,
            borderingContinents: ["North America", "Europe", "Asia"],
            funFact: "The Arctic Ocean is the smallest and shallowest ocean, mostly covered by sea ice in winter.",
            icon: "snowflake",
            isOcean: true
        ),
        Ocean(
            id: "southern",
            name: "Southern Ocean",
            area: 21_960_000,
            averageDepth: 3_270,
            maxDepth: 7_236,
            borderingContinents: ["Antarctica"],
            funFact: "The Southern Ocean became Earth's fifth ocean when National Geographic recognized it in 2021.",
            icon: "wind.snow",
            isOcean: true
        ),
        Ocean(
            id: "mediterranean",
            name: "Mediterranean Sea",
            area: 2_500_000,
            averageDepth: 1_500,
            maxDepth: 5_267,
            borderingContinents: ["Europe", "Africa", "Asia"],
            funFact: "The Mediterranean nearly dried up 6 million years ago during the Messinian Salinity Crisis.",
            icon: "sun.max",
            isOcean: false
        ),
        Ocean(
            id: "caribbean",
            name: "Caribbean Sea",
            area: 2_754_000,
            averageDepth: 2_200,
            maxDepth: 7_686,
            borderingContinents: ["North America", "South America"],
            funFact: "The Caribbean is home to the second-largest barrier reef in the world — the Mesoamerican Reef.",
            icon: "leaf",
            isOcean: false
        ),
        Ocean(
            id: "red_sea",
            name: "Red Sea",
            area: 438_000,
            averageDepth: 491,
            maxDepth: 3_040,
            borderingContinents: ["Africa", "Asia"],
            funFact: "The Red Sea has some of the world's saltiest water due to high evaporation and no river inflows.",
            icon: "drop.fill",
            isOcean: false
        ),
        Ocean(
            id: "black_sea",
            name: "Black Sea",
            area: 436_402,
            averageDepth: 1_253,
            maxDepth: 2_212,
            borderingContinents: ["Europe", "Asia"],
            funFact: "The deep waters of the Black Sea are completely devoid of oxygen below 150-200 meters depth.",
            icon: "moon.fill",
            isOcean: false
        ),
        Ocean(
            id: "south_china",
            name: "South China Sea",
            area: 3_500_000,
            averageDepth: 1_212,
            maxDepth: 5_016,
            borderingContinents: ["Asia"],
            funFact: "The South China Sea accounts for about one-third of the world's maritime trade traffic.",
            icon: "ferry",
            isOcean: false
        ),
        Ocean(
            id: "caspian",
            name: "Caspian Sea",
            area: 371_000,
            averageDepth: 211,
            maxDepth: 1_025,
            borderingContinents: ["Europe", "Asia"],
            funFact: "Despite its name, the Caspian Sea is actually the world's largest lake — fully landlocked.",
            icon: "mountain.2",
            isOcean: false
        ),
        Ocean(
            id: "arabian",
            name: "Arabian Sea",
            area: 3_862_000,
            averageDepth: 2_734,
            maxDepth: 5_803,
            borderingContinents: ["Asia", "Africa"],
            funFact: "The Arabian Sea hosts some of the world's busiest shipping lanes from the Gulf of Aden to India.",
            icon: "wind",
            isOcean: false
        ),
        Ocean(
            id: "coral",
            name: "Coral Sea",
            area: 4_791_000,
            averageDepth: 2_394,
            maxDepth: 9_140,
            borderingContinents: ["Australia"],
            funFact: "The Coral Sea hosts the Great Barrier Reef — the world's largest coral reef at 2,300 km long.",
            icon: "waveform.path.ecg",
            isOcean: false
        ),
    ]

    public var oceansList: [Ocean] { oceans.filter { $0.isOcean } }
    public var seasList: [Ocean] { oceans.filter { !$0.isOcean } }
}
