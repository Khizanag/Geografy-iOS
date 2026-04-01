import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Feature_IndependenceTimeline

struct IndependenceScreen: View {
    private let service = IndependenceTimelineService()

    @State private var selectedEra: IndependenceEra?

    private var displayedEvents: [IndependenceEvent] {
        guard let selectedEra else {
            return service.events.sorted { $0.year > $1.year }
        }
        return service.events(for: selectedEra).sorted { $0.year > $1.year }
    }

    var body: some View {
        List {
            Section {
                Picker("Era", selection: $selectedEra) {
                    Text("All").tag(nil as IndependenceEra?)
                    ForEach(IndependenceEra.allCases, id: \.self) { era in
                        Text(era.rawValue)
                            .tag(era as IndependenceEra?)
                    }
                }
            }

            Section("\(displayedEvents.count) countries") {
                ForEach(displayedEvents) { event in
                    HStack(spacing: 20) {
                        FlagView(countryCode: event.countryCode, height: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.countryName)
                                .font(.system(size: 22, weight: .semibold))

                            Text(event.description)
                                .font(.system(size: 22))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(event.year)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(DesignSystem.Color.accent)

                            if !event.independenceFrom.isEmpty {
                                Text("from \(event.independenceFrom)")
                                    .font(.system(size: 22))
                                    .foregroundStyle(DesignSystem.Color.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Independence Timeline")
    }
}
