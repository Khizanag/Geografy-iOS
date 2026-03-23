# Territorial Disputes Analysis

Deep analysis of all significant territorial disputes worldwide, with UI picker recommendations for the Geografy app.

> **IMPORTANT**: Abkhazia and South Ossetia (Samachablo) are **NOT** disputed — they are internationally recognized as Georgia. Do not list them.

---

## Currently Implemented (in TerritorialDispute.swift)

| ID | Name | Default |
|----|------|---------|
| `kosovo` | Kosovo | Separate (Republic of Kosovo) |
| `northern_cyprus` | Northern Cyprus | Part of Cyprus |
| `crimea` | Crimea | Part of Ukraine |
| `transnistria` | Transnistria | Part of Moldova |
| `palestine` | Palestine | State of Palestine |
| `taiwan` | Taiwan | Republic of China (Taiwan) |
| `golan_heights` | Golan Heights | Part of Syria |
| `kashmir` | Kashmir | Disputed (as shown) |
| `western_sahara` | Western Sahara | Part of Morocco |
| `somaliland` | Somaliland | Part of Somalia |
| `falkland_islands` | Falkland Islands | British Territory |

---

## Europe

### Kosovo ✅ Implemented
- **Parties**: Kosovo (declared independence 2008) vs. Serbia
- **Nature**: Post-Yugoslav war independence declaration; ~100 UN states recognize Kosovo, Serbia and Russia do not
- **Status**: Ongoing. ICJ 2010 advisory opinion: declaration didn't violate international law
- **Picker options**:
  - "Republic of Kosovo" (separate) — **DEFAULT**
  - "Part of Serbia"
- **Notes**: EU-brokered Brussels Agreement attempts normalization. NATO (KFOR) peacekeeping presence

### Northern Cyprus ✅ Implemented
- **Parties**: Turkish Republic of Northern Cyprus (TRNC) vs. Republic of Cyprus (internationally recognized)
- **Nature**: 1974 Turkish military intervention after Greek coup; TRNC declared in 1983, recognized only by Turkey
- **Status**: Divided by UN Buffer Zone ("Green Line"). Reunification talks ongoing, most recent failure 2017
- **Picker options**:
  - "Part of Cyprus" (merges into CY) — **DEFAULT**
  - "Separate (TRNC)"

### Crimea ✅ Implemented
- **Parties**: Ukraine vs. Russia
- **Nature**: Russia annexed in 2014 following military intervention; 100 UN members affirmed Ukraine's territorial integrity
- **Status**: Russian-controlled but internationally unrecognized annexation. Contested during 2022–present war
- **Picker options**:
  - "Part of Ukraine" (merges into UA) — **DEFAULT**
  - "Part of Russia" (merges into RU)

### Transnistria ✅ Implemented
- **Parties**: Moldova vs. Pridnestrovian Moldavian Republic (PMR)
- **Nature**: Russian-backed breakaway since 1992 war; unrecognized by any UN member state including Russia
- **Status**: Frozen conflict; Russian troops stationed. Russian gas subsidies ended 2025, causing energy crisis
- **Picker options**:
  - "Part of Moldova" (merges into MD) — **DEFAULT**
  - "Separate (unrecognized)"

### Nagorno-Karabakh ⚠️ MISSING — IMPORTANT
- **Parties**: Armenia vs. Azerbaijan; region populated by ethnic Armenians
- **Nature**: Disputed since the Soviet era; war in 1991–94, 2020 war won by Azerbaijan, 2023 Azerbaijan military operation ended Armenian control
- **Status**: As of late 2023, Azerbaijan controls the entire region; the Armenian population (~100,000) fled. The Nagorno-Karabakh Republic self-dissolved December 2023
- **Geographic presence**: Appears on many maps as a distinct region (GeoJSON: "Nagorno-Karabakh")
- **Picker options**:
  - "Part of Azerbaijan" (merges into AZ) — **DEFAULT** (reflects current reality post-2023)
  - "Historical: Artsakh Republic" (separate, historical)
- **Recommendation**: Default to Azerbaijan given the 2023 resolution, but acknowledge the historical context

### Donbas / Eastern Ukraine ⚠️ MISSING — IMPORTANT
- **Parties**: Ukraine vs. Russia-backed separatists / Russia (since 2022 annexation claims)
- **Nature**: Russia claimed annexation of Donetsk, Luhansk, Zaporizhzhia, Kherson oblasts in Sep 2022; not recognized by UN (143-5 vote against)
- **Status**: Active war zone. Ukraine controls large portions of all four claimed oblasts
- **Picker options**:
  - "Part of Ukraine" (merges into UA) — **DEFAULT**
  - "Russian-claimed (unrecognized)"
- **Notes**: GeoJSON typically doesn't show these separately; may not need a separate territory entry — can be noted in the Crimea entry's description

### Gibraltar ⚠️ MISSING
- **Parties**: United Kingdom vs. Spain
- **Nature**: British Overseas Territory since 1713 Treaty of Utrecht; Spain claims historical sovereignty; residents vote consistently to remain British (1967: 99.6%, 2002: 98.5%)
- **Status**: Ongoing diplomatic dispute; post-Brexit negotiations about status
- **Picker options**:
  - "British Territory (Gibraltar)" — **DEFAULT**
  - "Part of Spain"

### Ceuta & Melilla ⚠️ MISSING
- **Parties**: Spain vs. Morocco
- **Nature**: Two Spanish autonomous cities on the North African coast; Morocco claims them
- **Status**: Ongoing; Spain's position is firm; not the same profile as most disputes
- **Recommendation**: Lower priority — typically shown as Spanish. Mention in Ceuta/Melilla note if GeoJSON has them separately

### Isle of Man / Channel Islands
- Technically British Crown Dependencies, not disputed territories — skip

### Åland Islands
- Finnish autonomous region, Swedish-speaking; demilitarized zone; not disputed in the modern sense — skip

---

## Middle East & Asia

### Palestine ✅ Implemented
- **Parties**: State of Palestine (PLO/PA) vs. Israel; Hamas controls Gaza
- **Nature**: UN observer state (since 2012) recognized by 146 states; Israel does not recognize; the West Bank and Gaza have complex overlapping jurisdictions
- **Status**: Active conflict since October 2023 Gaza war; West Bank settlements expand
- **Picker options**:
  - "State of Palestine" (separate) — **DEFAULT**
  - "Israeli-administered"
- **Notes**: Should distinguish West Bank (PA-administered) and Gaza (Hamas) in any future fine-grained implementation

### Taiwan ✅ Implemented
- **Parties**: Republic of China (Taiwan) vs. People's Republic of China
- **Nature**: ROC government fled to Taiwan in 1949 after Chinese Civil War; PRC claims Taiwan as a province; ~12 states recognize ROC; most others use "one China" policy without formal recognition of PRC's territorial claims
- **Status**: Cross-strait tensions remain high; no formal peace treaty exists
- **Picker options**:
  - "Republic of China (Taiwan)" (separate) — **DEFAULT**
  - "Part of China (PRC)"

### Golan Heights ✅ Implemented
- **Parties**: Israel vs. Syria
- **Nature**: Captured in 1967 Six-Day War; Israel annexed 1981; UN Resolution 497 declared annexation null; US recognized Israeli sovereignty in 2019
- **Status**: Effectively under Israeli administration; Syria's civil war weakens its claims
- **Picker options**:
  - "Part of Syria" — **DEFAULT** (international law position)
  - "Part of Israel" (US recognition position)

### Kashmir ✅ Implemented
- **Parties**: India, Pakistan, China (each controls portions)
- **Nature**: Maharaja acceded to India at 1947 partition but Pakistan disputed; first war 1947–48; Line of Control established; China occupies Aksai Chin
- **Status**: Frozen; India revoked J&K's special status (Article 370) in 2019 and split into two Union Territories
- **Picker options**:
  - "Disputed (as shown)" — **DEFAULT**
  - "Part of India"
  - "Part of Pakistan"
- **Notes**: Chinese-controlled Aksai Chin is a separate dispute but shown as part of the same area

### Aksai Chin ⚠️ Consider adding
- **Parties**: India vs. China
- **Nature**: China controls it; India claims it; part of the broader Sino-Indian border dispute
- **Status**: Frozen; occasional skirmishes along LAC (Line of Actual Control); 2020 Galwan Valley clash
- **Picker options**:
  - "Disputed (China-administered)" — **DEFAULT**
  - "Part of China"
  - "Part of India"
- **Notes**: Could be folded into Kashmir entry

### Arunachal Pradesh ⚠️ Consider adding
- **Parties**: India vs. China (China calls it "South Tibet" / "Zangnan")
- **Nature**: Administered by India; China claims most of it
- **Status**: India's control is firm; recurring Chinese renaming of towns
- **Picker options**:
  - "Part of India" — **DEFAULT**
  - "Disputed (China claims)"
- **Notes**: Low-priority for map since India controls and administers it

### Spratly Islands ⚠️ MISSING
- **Parties**: China, Vietnam, Philippines, Malaysia, Brunei, Taiwan (all claim various features)
- **Nature**: Strategic archipelago in the South China Sea; overlapping claims; China built artificial islands with military facilities
- **Status**: Active dispute; PCA 2016 ruling invalidated China's "nine-dash line" (China rejected ruling)
- **Picker options**:
  - "Disputed (multiple claims)" — **DEFAULT**
  - "Part of China" (PRC position)
  - "Part of Philippines"
  - "Part of Vietnam"

### Paracel Islands ⚠️ MISSING
- **Parties**: China vs. Vietnam (Taiwan also claims)
- **Nature**: China seized from South Vietnam in 1974; China now controls all islands; Vietnam maintains claim
- **Status**: Chinese-controlled; Vietnamese fishing vessels occasionally harassed
- **Picker options**:
  - "Part of China" — **DEFAULT** (de facto control)
  - "Part of Vietnam" (Vietnamese legal position)

### Senkaku/Diaoyu Islands ⚠️ MISSING
- **Parties**: Japan vs. China vs. Taiwan
- **Nature**: Uninhabited islands administered by Japan since 1972 reversion; China claims historical sovereignty ("Diaoyu"); Taiwan also claims ("Diaoyutai")
- **Status**: Japan administers; regular PRC coast guard intrusions; no resolution
- **Picker options**:
  - "Part of Japan (Senkaku)" — **DEFAULT** (administrative reality)
  - "Part of China (Diaoyu)"

### Dokdo/Takeshima Islands ⚠️ Consider adding
- **Parties**: South Korea vs. Japan
- **Nature**: Small rocky islands administered by South Korea; Japan claims them; third countries officially neutral
- **Status**: South Korea has coastguard post; highly politically sensitive
- **Picker options**:
  - "Part of South Korea (Dokdo)" — **DEFAULT**
  - "Part of Japan (Takeshima)"
- **Notes**: Lower profile globally; important for Korean/Japanese users

### Scarborough Shoal
- **Parties**: China vs. Philippines
- **Nature**: Philippines claimed; China seized effective control in 2012; PCA ruled for Philippines 2016
- **Status**: De facto Chinese control; part of broader SCS dispute
- **Could fold into**: Spratly Islands entry or a "South China Sea" combined entry

---

## Africa

### Western Sahara ✅ Implemented
- **Parties**: Morocco vs. Sahrawi Arab Democratic Republic (SADR) / Polisario Front
- **Nature**: Former Spanish colony; Morocco moved in 1975 (Green March); Spain withdrew; SADR declared; African Union recognizes SADR; US recognized Moroccan sovereignty in 2020
- **Status**: Mostly frozen; Morocco controls ~80% and builds a Berm wall; Polisario controls eastern desert
- **Picker options**:
  - "Part of Morocco" — **DEFAULT** (de facto control; many maps show it this way)
  - "Sahrawi Republic (SADR)"

### Somaliland ✅ Implemented
- **Parties**: Somaliland Republic vs. Federal Republic of Somalia
- **Nature**: Self-declared 1991; stable democratic republic; internationally unrecognized but de facto independent
- **Status**: Ongoing; Ethiopia signed a controversial MOU in 2024 that partially recognized Somaliland access
- **Picker options**:
  - "Part of Somalia" — **DEFAULT**
  - "Separate (Somaliland)"

### Puntland ⚠️ MISSING
- **Parties**: Puntland State vs. Federal Somalia
- **Nature**: Autonomous region of Somalia since 1998; claims to be within Somalia but semi-autonomous
- **Status**: Less contentious than Somaliland; accepts being part of Somalia in theory
- **Recommendation**: Low priority — typically shown as Somalia

### Tigray / Ethiopia
- Not a territorial dispute per se but an internal conflict (2020–2022); show as Ethiopia — skip

### Cabinda ⚠️ Consider adding
- **Parties**: Angola vs. Cabinda enclave separatists (FLEC)
- **Nature**: Oil-rich exclave separated from main Angola by DRC corridor; low-level insurgency since 1975
- **Status**: Angola administers firmly; low international profile
- **Recommendation**: Low priority — show as Angola

### Hala'ib Triangle ⚠️ Consider adding
- **Parties**: Egypt vs. Sudan
- **Nature**: Both claim; Egypt administers the larger Hala'ib Triangle; Sudan claims Bir Tawil is no-man's land (because taking Hala'ib means ceding Bir Tawil)
- **Picker options**:
  - "Part of Egypt" — **DEFAULT** (administrative reality)
  - "Disputed (Egypt/Sudan)"

---

## Americas

### Falkland Islands ✅ Implemented
- **Parties**: United Kingdom vs. Argentina ("Islas Malvinas")
- **Nature**: British since 1833; Argentina invaded in 1982 (Falklands War); UK retook after 74-day conflict; residents vote overwhelmingly British (2013: 99.8%)
- **Status**: Ongoing diplomatic dispute; UK has firm legal/democratic standing
- **Picker options**:
  - "British Territory (Falklands)" — **DEFAULT**
  - "Argentine Territory (Malvinas)" (merges into AR)

### South Georgia & South Sandwich Islands ⚠️ Consider adding
- **Parties**: UK vs. Argentina
- **Nature**: British Overseas Territories; Argentina claims as part of Malvinas claim
- **Status**: UK administers; no permanent population
- **Recommendation**: Can bundle with Falklands in a single "Southern Atlantic Islands" entry or mention in Falklands description

### Guyana-Venezuela (Essequibo) ⚠️ MISSING
- **Parties**: Venezuela vs. Guyana
- **Nature**: Venezuela claims the Essequibo region (~70% of Guyana's territory); settled 1899 by international arbitration; Venezuela renewed claim in 1962
- **Status**: Active: December 2023 referendum in Venezuela endorsed taking Essequibo; Guyana has ICJ case; oil discovered offshore
- **GeoJSON**: Often shown separately as "Esequibo" on some map sources
- **Picker options**:
  - "Part of Guyana" (merges into GY) — **DEFAULT** (international consensus)
  - "Disputed (Venezuelan claim)"

### Belize-Guatemala
- **Parties**: Guatemala vs. Belize
- **Nature**: Guatemala claimed all of Belize for decades; recognized Belize 1991 but reserved territorial claim to southern half
- **Status**: ICJ case ongoing since 2019 referendums; Belize administers full territory
- **Picker options**:
  - "Belize" — **DEFAULT**
  - "Disputed (Guatemala claim)"

---

## Pacific

### New Caledonia ⚠️ MISSING
- **Parties**: France vs. independence movement (FLNKS)
- **Nature**: French special collectivity; three independence referendums (2018, 2020, 2021) all rejected independence but with rising yes votes
- **Status**: Post-referendum political crisis; 2024 unrest
- **Picker options**:
  - "French Territory (New Caledonia)" — **DEFAULT**
  - "Separate (Kanaky)"
- **Notes**: French overseas territories may be out of scope for initial implementation

### French Polynesia / Tahiti
- Autonomous French collectivity; no serious independence movement recently — skip

---

## Summary: Recommended Additions (Priority Order)

| Priority | Territory | Reason |
|----------|-----------|--------|
| **HIGH** | Nagorno-Karabakh | Major 2023 resolution; many maps still show it |
| **HIGH** | Essequibo (Guyana-Venezuela) | Active 2023–present dispute; ICJ case |
| **HIGH** | Spratly Islands | Major geopolitical dispute; large area |
| **MEDIUM** | Gibraltar | Well-known; UK-Spain |
| **MEDIUM** | Senkaku/Diaoyu | Japan-China; important for East Asian users |
| **MEDIUM** | Paracel Islands | China-Vietnam; related to Spratlys |
| **LOW** | Donbas | Complex; war zone; GeoJSON doesn't distinguish clearly |
| **LOW** | Aksai Chin | Part of Kashmir entry already |
| **LOW** | Dokdo/Takeshima | Niche but important for Korean/Japanese |
| **LOW** | Hala'ib Triangle | Obscure; small |

---

## UI Picker Design Recommendations

### Option Display
Each dispute should show in Settings with:
```
[Flag emoji] Territory Name
   Short description (1 line)
   ○ Option A  (checkmark if selected)
   ○ Option B
   ○ Option C (if 3-way)
```

### Defaults Philosophy
- Default to the **internationally recognized position** (UN majority view)
- For de facto control that differs from legal position, note it clearly
- Avoid political bias in descriptions — state facts, not opinions

### Grouping
Keep the current `Region` enum:
- Europe: Kosovo, Northern Cyprus, Crimea, Transnistria, Gibraltar, Nagorno-Karabakh
- Middle East & Asia: Palestine, Taiwan, Golan Heights, Kashmir, Aksai Chin, Spratly Islands, Senkaku/Diaoyu
- Africa: Western Sahara, Somaliland, Hala'ib Triangle
- Americas: Falkland Islands, Essequibo, Belize/Guatemala

### Map Behavior
- When a territory "merges into" a country (`mergesInto: "UA"`), the territory's GeoJSON shape is not rendered separately; the parent country's shape covers it
- When `mergesInto` is nil (separate), the territory renders as its own polygon with a distinct color
- For three-way disputes (Kashmir), "disputed" shows the current GeoJSON as-is without merging

---

## Data Sources

- UN resolutions and voting records: un.org
- ICJ decisions: icj-cij.org
- Natural Earth GeoJSON `sovereignt` and `admin` fields: naturalearthdata.com
- Wikipedia "territorial dispute" category for current status
