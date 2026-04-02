import Foundation
import Geografy_Core_Common

@Observable
public final class NationalSymbolsService {
    public init() {}
    public private(set) var symbols: [NationalSymbol] = NationalSymbolsService.allSymbols

    public func symbol(for countryCode: String) -> NationalSymbol? {
        symbols.first { $0.countryCode == countryCode }
    }
}

// MARK: - Data
private extension NationalSymbolsService {
    nonisolated(unsafe) public static let allSymbols: [NationalSymbol] = [
        NationalSymbol(
            id: "US", countryCode: "US",
            animal: "Bald Eagle", flower: "Rose",
            sport: "Baseball", motto: "In God We Trust",
            funFact: "The bald eagle was chosen as a symbol in 1782 for its long life and majestic presence."
        ),
        NationalSymbol(
            id: "GB", countryCode: "GB",
            animal: "Lion", flower: "Tudor Rose",
            sport: "Cricket", motto: "God Save the King",
            funFact: "Despite the lion being Britain's symbol, lions have never been native to Britain."
        ),
        NationalSymbol(
            id: "FR", countryCode: "FR",
            animal: "Gallic Rooster", flower: "Iris",
            sport: "Football", motto: "Liberté, Égalité, Fraternité",
            funFact: "The Gallic Rooster was a symbol of resistance and courage during the French Revolution."
        ),
        NationalSymbol(
            id: "CA", countryCode: "CA",
            animal: "Beaver", flower: "Maple Leaf",
            sport: "Ice Hockey", motto: "A Mari Usque Ad Mare",
            funFact: "The beaver became Canada's symbol for its central role in the fur trade."
        ),
        NationalSymbol(
            id: "AU", countryCode: "AU",
            animal: "Kangaroo", flower: "Golden Wattle",
            sport: "Cricket", motto: "Advance Australia Fair",
            funFact: "The kangaroo appears on the coat of arms because it cannot walk backwards."
        ),
        NationalSymbol(
            id: "JP", countryCode: "JP",
            animal: "Japanese Crane", flower: "Chrysanthemum",
            sport: "Sumo Wrestling", motto: "",
            funFact: "The chrysanthemum is Japan's imperial seal, associated with the emperor since the 8th century."
        ),
        NationalSymbol(
            id: "DE", countryCode: "DE",
            animal: "Eagle", flower: "Cornflower",
            sport: "Football", motto: "Einigkeit und Recht und Freiheit",
            funFact: "The German eagle (Bundesadler) dates back to Charlemagne's reign in the 9th century."
        ),
        NationalSymbol(
            id: "BR", countryCode: "BR",
            animal: "Jaguar", flower: "Cattleya Orchid",
            sport: "Football", motto: "Ordem e Progresso",
            funFact: "Brazil's motto 'Order and Progress' is taken from Auguste Comte's positivism motto."
        ),
        NationalSymbol(
            id: "IN", countryCode: "IN",
            animal: "Bengal Tiger", flower: "Lotus",
            sport: "Cricket", motto: "Satyameva Jayate",
            funFact: "The Bengal Tiger replaced the lion as India's national animal in 1973."
        ),
        NationalSymbol(
            id: "CN", countryCode: "CN",
            animal: "Giant Panda", flower: "Plum Blossom",
            sport: "Table Tennis", motto: "",
            funFact: "China has used giant pandas as diplomatic gifts since the Tang dynasty around 685 AD."
        ),
        NationalSymbol(
            id: "RU", countryCode: "RU",
            animal: "Brown Bear", flower: "Chamomile",
            sport: "Ice Hockey", motto: "",
            funFact: "Russia's brown bear symbolises strength and the country has the world's largest bear population."
        ),
        NationalSymbol(
            id: "ZA", countryCode: "ZA",
            animal: "Springbok", flower: "King Protea",
            sport: "Rugby", motto: "Unity in Diversity",
            funFact: "The King Protea is the largest of the protea species, symbolising South Africa's beauty."
        ),
        NationalSymbol(
            id: "NZ", countryCode: "NZ",
            animal: "Kiwi", flower: "Silver Fern",
            sport: "Rugby", motto: "Onward",
            funFact: "The kiwi is flightless and nocturnal, laying the largest egg relative to body size of any bird."
        ),
        NationalSymbol(
            id: "AR", countryCode: "AR",
            animal: "Rufous Hornero", flower: "Ceibo",
            sport: "Football", motto: "En unión y libertad",
            funFact: "The Rufous Hornero builds oven-shaped mud nests, earning it the name 'baker' in Spanish."
        ),
        NationalSymbol(
            id: "NL", countryCode: "NL",
            animal: "Lion", flower: "Tulip",
            sport: "Football", motto: "Je maintiendrai",
            funFact: "Though tulips are the Netherlands' symbol, they were originally imported from the Ottoman Empire."
        ),
        NationalSymbol(
            id: "IT", countryCode: "IT",
            animal: "Italian Wolf", flower: "Lily",
            sport: "Football", motto: "",
            funFact: "The wolf is sacred in Italian culture — legend says Romulus and Remus were raised by a she-wolf."
        ),
        NationalSymbol(
            id: "ES", countryCode: "ES",
            animal: "Bull", flower: "Carnation",
            sport: "Football", motto: "Plus Ultra",
            funFact: "Spain's motto 'Plus Ultra' (Further Beyond) was adopted after the discovery of the Americas."
        ),
        NationalSymbol(
            id: "MX", countryCode: "MX",
            animal: "Golden Eagle", flower: "Dahlia",
            sport: "Football", motto: "",
            funFact: "The dahlia, Mexico's national flower, was first cultivated by the Aztecs as a food source."
        ),
        NationalSymbol(
            id: "PK", countryCode: "PK",
            animal: "Markhor", flower: "Jasmine",
            sport: "Cricket", motto: "Faith, Unity, Discipline",
            funFact: "The markhor is a wild goat native to Pakistan's mountains, among the largest goat family members."
        ),
        NationalSymbol(
            id: "EG", countryCode: "EG",
            animal: "Steppe Eagle", flower: "Lotus",
            sport: "Football", motto: "",
            funFact: "The lotus was sacred to ancient Egyptians — it closes at night and reopens at dawn."
        ),
        NationalSymbol(
            id: "NG", countryCode: "NG",
            animal: "Eagle", flower: "Costus Spectabilis",
            sport: "Football", motto: "Unity and Faith, Peace and Progress",
            funFact: "Costus Spectabilis blooms across Nigeria's savanna and is known as the 'pride of Nigeria.'"
        ),
        NationalSymbol(
            id: "KE", countryCode: "KE",
            animal: "Lion", flower: "Strelitzia",
            sport: "Athletics", motto: "Harambee",
            funFact: "'Harambee' means 'all pull together' in Swahili, reflecting Kenya's community spirit."
        ),
        NationalSymbol(
            id: "TH", countryCode: "TH",
            animal: "Asian Elephant", flower: "Ratchaphruek",
            sport: "Muay Thai", motto: "Nation, Religions, King",
            funFact: "The white elephant is sacred in Thailand and historically only belonged to the king."
        ),
        NationalSymbol(
            id: "TR", countryCode: "TR",
            animal: "Grey Wolf", flower: "Tulip",
            sport: "Oil Wrestling", motto: "Peace at Home, Peace in the World",
            funFact: "Turkish oil wrestling (Kırkpınar) is the world's oldest continuously sanctioned sporting event."
        ),
        NationalSymbol(
            id: "SE", countryCode: "SE",
            animal: "Eurasian Elk", flower: "Linnaea Borealis",
            sport: "Football", motto: "För Sverige i tiden",
            funFact: "The twinflower was Carl Linnaeus's favourite plant and is named in his honour."
        ),
        NationalSymbol(
            id: "NO", countryCode: "NO",
            animal: "White-throated Dipper", flower: "Purple Heather",
            sport: "Cross-country Skiing", motto: "Alt for Norge",
            funFact: "The White-throated Dipper can walk along riverbeds underwater to find food."
        ),
        NationalSymbol(
            id: "PL", countryCode: "PL",
            animal: "White-tailed Eagle", flower: "Red Poppy",
            sport: "Football", motto: "God, Honour, Homeland",
            funFact: "Poland's white eagle has been a national symbol since the 13th century."
        ),
        NationalSymbol(
            id: "GR", countryCode: "GR",
            animal: "Dolphin", flower: "Violet",
            sport: "Football", motto: "Freedom or Death",
            funFact: "In ancient Greece, dolphins were messengers of the gods — killing one was considered sacrilege."
        ),
        NationalSymbol(
            id: "PT", countryCode: "PT",
            animal: "Barcelos Rooster", flower: "Lavender",
            sport: "Football", motto: "This is the Proud and Beautiful Portugal",
            funFact: "Legend says a roasted rooster came back to life to prove a pilgrim's innocence."
        ),
        NationalSymbol(
            id: "IE", countryCode: "IE",
            animal: "Irish Hare", flower: "Shamrock",
            sport: "Gaelic Football", motto: "We are ready",
            funFact: "St. Patrick used the shamrock's three leaves to explain the Holy Trinity."
        ),
        NationalSymbol(
            id: "CH", countryCode: "CH",
            animal: "Marmot", flower: "Edelweiss",
            sport: "Schwingen", motto: "One for all, all for one",
            funFact: "The edelweiss grows in rocky alpine terrain and was given as proof of bravery to loved ones."
        ),
        NationalSymbol(
            id: "BE", countryCode: "BE",
            animal: "Golden Eagle", flower: "Red Poppy",
            sport: "Cycling", motto: "Unity makes strength",
            funFact: "Belgium is home to the Tour of Flanders, one of cycling's most prestigious classics since 1913."
        ),
        NationalSymbol(
            id: "AT", countryCode: "AT",
            animal: "Barn Swallow", flower: "Edelweiss",
            sport: "Alpine Skiing", motto: "",
            funFact: "Austria has won more alpine skiing World Cup titles than any other nation."
        ),
        NationalSymbol(
            id: "CZ", countryCode: "CZ",
            animal: "Double-tailed Lion", flower: "Small-leaved Linden",
            sport: "Ice Hockey", motto: "Truth Prevails",
            funFact: "The linden is sacred in Czech culture — villages traditionally held meetings under its shade."
        ),
        NationalSymbol(
            id: "HU", countryCode: "HU",
            animal: "Turul Bird", flower: "Tulip",
            sport: "Water Polo", motto: "With God for Country and King",
            funFact: "The Turul is a mythical falcon that led the Magyar tribes to the Carpathian Basin in 895 AD."
        ),
        NationalSymbol(
            id: "PH", countryCode: "PH",
            animal: "Philippine Eagle", flower: "Sampaguita",
            sport: "Basketball", motto: "For God, People, Nature, and Country",
            funFact: "The Philippine Eagle is one of the world's largest eagles, with a wingspan up to 2.2 metres."
        ),
        NationalSymbol(
            id: "MY", countryCode: "MY",
            animal: "Malayan Tiger", flower: "Hibiscus",
            sport: "Badminton", motto: "Unity is Strength",
            funFact: "The hibiscus symbolises the five pillars of Islam — courage, life, growth, wealth, and purity."
        ),
        NationalSymbol(
            id: "ID", countryCode: "ID",
            animal: "Komodo Dragon", flower: "Jasmine",
            sport: "Badminton", motto: "Unity in Diversity",
            funFact: "Indonesia is the only country with the Komodo dragon, the world's largest living lizard."
        ),
        NationalSymbol(
            id: "SA", countryCode: "SA",
            animal: "Arabian Horse", flower: "Arabian Coffee",
            sport: "Equestrian", motto: "",
            funFact: "The Arabian horse is one of the world's oldest breeds, developed over 4,500 years ago."
        ),
        NationalSymbol(
            id: "CL", countryCode: "CL",
            animal: "Andean Condor", flower: "Red Copihue",
            sport: "Football", motto: "By reason or by force",
            funFact: "The Andean condor has one of the largest wingspans of any land bird — up to 3.3 metres."
        ),
        NationalSymbol(
            id: "CO", countryCode: "CO",
            animal: "Andean Condor", flower: "Christmas Orchid",
            sport: "Cycling", motto: "Freedom and Order",
            funFact: "Colombia produces 80% of the world's supply of the Christmas orchid (Cattleya trianae)."
        ),
        NationalSymbol(
            id: "PE", countryCode: "PE",
            animal: "Vicuña", flower: "Cantuta",
            sport: "Football", motto: "Firm and Happy for the Union",
            funFact: "The vicuña produces the world's finest wool — only Inca royalty could wear garments made from it."
        ),
    ]
}
