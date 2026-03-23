# Multiple Capitals Data

Countries with more than one capital city, including which capital serves which function.

---

## Tier 1: Officially Multiple Capitals (Constitutional/Legal Recognition)

### South Africa — 3 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Pretoria (Tshwane)** | Executive capital | Seat of the presidency and national government; government ministries |
| **Cape Town** | Legislative capital | Parliament sits here |
| **Bloemfontein** | Judicial capital | Supreme Court of Appeal |

- **Country code**: ZA
- **Historical reason**: Compromise during the 1910 Union of South Africa between Boer and British territories; distributes power among former colonies
- **De facto**: Pretoria is what most people consider "the capital" for everyday purposes

---

### Bolivia — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Sucre** | Constitutional / Judicial capital | Historic seat; Supreme Tribunal of Justice; original capital |
| **La Paz** | Executive / Legislative capital (seat of government) | Where the president, cabinet, and legislature actually sit |

- **Country code**: BO
- **Historical reason**: 1899 Federal War — La Paz (Liberal) won, but Sucre (Conservative) retained some functions as compromise
- **Altitude**: La Paz (~3,640m) is the world's highest seat of government; Sucre (~2,750m)
- **Display note**: `countries.json` likely lists La Paz as the capital — both should be shown in Country Detail

---

### Malaysia — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Kuala Lumpur** | National capital (official) | Financial, commercial, cultural center; parliament building |
| **Putrajaya** | Federal administrative capital | Built 1999; all government ministries and agencies; PM's office |

- **Country code**: MY
- **Historical reason**: KL became too congested; Putrajaya purpose-built to relieve pressure
- **Display note**: KL is the official capital; Putrajaya is the administrative capital — both worth showing

---

### Myanmar — Historical context (capital moved)
| City | Function | Notes |
|------|----------|-------|
| **Naypyidaw** | Official capital (since 2006) | Purpose-built; government, military; eerily empty |
| **Yangon (Rangoon)** | Former capital; largest city; commercial hub | More people actually live and work here |

- **Country code**: MM
- **Historical reason**: Junta moved capital in 2006, widely seen as strategic/astrological decision; keeps government away from coastal attack
- **Display note**: `countries.json` should show Naypyidaw as capital; Yangon as largest city/former capital

---

### Tanzania — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Dodoma** | Official / Legislative capital (since 1996) | Parliament moved here; constitutional capital |
| **Dar es Salaam** | Commercial capital; de facto administrative center | Most government functions still here; largest city |

- **Country code**: TZ
- **Historical reason**: Dodoma is more central; inland location avoids coastal concentration
- **Status**: Transition incomplete; most ministries still in Dar es Salaam

---

### Ivory Coast (Côte d'Ivoire) — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Yamoussoukro** | Official / Political capital (since 1983) | Hometown of Félix Houphouët-Boigny; home of the Basilica of Our Lady of Peace |
| **Abidjan** | Economic / Administrative capital (de facto) | Financial hub; most embassies; largest city |

- **Country code**: CI
- **Display note**: Most people (and maps) use Abidjan as "the capital" — both should be shown

---

### Sri Lanka — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Sri Jayawardenepura Kotte** | Legislative capital; official capital | Parliament; declared capital 1978 |
| **Colombo** | Executive / Commercial capital (de facto) | President's office; all government ministries; largest city; main port |

- **Country code**: LK
- **Display note**: Sri Jayawardenepura Kotte is effectively a suburb of Colombo (4 km away)

---

### Benin — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Porto-Novo** | Official / Legislative capital | Parliament; constitutional capital |
| **Cotonou** | Seat of government (de facto) | President's office; ministries; economic hub; largest city |

- **Country code**: BJ

---

### Eswatini (Swaziland) — 2 Capitals
| City | Function | Notes |
|------|----------|-------|
| **Mbabane** | Administrative / Executive capital | Government offices; largest city |
| **Lobamba** | Royal / Legislative capital | Parliament; Royal Kraal; national events |

- **Country code**: SZ

---

## Tier 2: Disputed / Complex Capital Status

### Israel — Disputed Capital
| City | Claim | Notes |
|------|-------|-------|
| **Jerusalem** | Declared capital by Israel (1950) | Government, Knesset, Supreme Court located here |
| **Tel Aviv** | Where most embassies are located | Many countries don't recognize Jerusalem due to Palestinian claims |

- **Country code**: IL
- **Status**: Most UN members do not recognize Jerusalem as Israel's capital due to its status as a final-status issue. The US recognized it in 2017 and moved its embassy in 2018. Most other countries keep embassies in Tel Aviv
- **Display recommendation**: Show Jerusalem as the capital with a note about diplomatic status; Tel Aviv as largest city / economic center

---

### Netherlands — Historical interest
| City | Function |
|------|----------|
| **Amsterdam** | Constitutional capital (by constitution) |
| **The Hague** | Seat of government (parliament, ministries, royal palace, International Court of Justice) |

- **Country code**: NL
- **Note**: Not truly "disputed" — Amsterdam is capital, The Hague is where the government actually sits. Common point of confusion worth noting in Country Detail

---

### Australia — Common confusion
| City | Function |
|------|----------|
| **Canberra** | Capital (since 1927) |
| **Sydney** | Largest city; common misconception that it's the capital |

- **Country code**: AU
- **Note**: Canberra was a compromise between Sydney and Melbourne rivalry

---

### Nigeria — Moved capital
| City | Function |
|------|----------|
| **Abuja** | Capital (since 1991) |
| **Lagos** | Former capital; still largest city and financial hub |

- **Country code**: NG
- **Note**: Capital moved to Abuja for central location and to reduce ethnic tensions

---

### Pakistan — Moved capital
| City | Function |
|------|----------|
| **Islamabad** | Capital (since 1966) |
| **Karachi** | Former capital; largest city; financial hub |

- **Country code**: PK

---

### Brazil — Moved capital
| City | Function |
|------|----------|
| **Brasília** | Capital (since 1960) |
| **Rio de Janeiro** | Former capital; second largest city |
| **São Paulo** | Largest city; financial capital |

- **Country code**: BR
- **Architect**: Oscar Niemeyer / Lúcio Costa; built in ~1,000 days

---

## Tier 3: Seasonal / Rotating Capitals

### South Africa (expanded note)
- Parliament alternates between Cape Town (legislative sessions) and Pretoria (executive) — the "three capitals" system is one of the most unusual in the world

---

## Countries Where App Should Show Multiple Capitals

Based on educational value, here are the countries where the Country Detail screen should explicitly list multiple capitals:

| Country | Primary (JSON) | Secondary | Note |
|---------|----------------|-----------|------|
| South Africa | Pretoria | Cape Town, Bloemfontein | Executive / Legislative / Judicial |
| Bolivia | Sucre | La Paz | Constitutional / Seat of govt |
| Malaysia | Kuala Lumpur | Putrajaya | Capital / Admin |
| Myanmar | Naypyidaw | Yangon | Official / Former/Commercial |
| Tanzania | Dodoma | Dar es Salaam | Official / De facto |
| Ivory Coast | Yamoussoukro | Abidjan | Official / De facto |
| Sri Lanka | Sri Jayawardenepura Kotte | Colombo | Official / Executive |
| Benin | Porto-Novo | Cotonou | Official / De facto |
| Eswatini | Mbabane | Lobamba | Admin / Royal |
| Netherlands | Amsterdam | The Hague | Capital / Seat of govt |
| Israel | Jerusalem | Tel Aviv | Declared / Diplomatic |

---

## Data Model Suggestion

The `Country` model could support:
```swift
struct Country {
    // ...
    let capital: String           // Primary capital (current)
    let capitals: [Capital]?      // All capitals if multiple

    struct Capital {
        let name: String
        let function: String     // "Executive", "Legislative", "Judicial", "Administrative"
        let latitude: Double
        let longitude: Double
    }
}
```

For countries with a single capital, `capitals` would be nil or contain one entry.
