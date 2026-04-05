import Geografy_Core_DesignSystem
import Geografy_Feature_IndependenceTimeline
import SwiftUI

struct IndependenceScreen: View {
    @State private var selectedEra: IndependenceEra?

    private let service = IndependenceTimelineService()

    private var displayedEvents: [IndependenceEvent] {
        guard let selectedEra else {
            return service.events.sorted(by: \.year, descending: true)
        }
        return service.events(for: selectedEra).sorted(by: \.year, descending: true)
    }

    var body: some View {
        // swiftlint:disable:next closure_body_length
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
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        FlagView(countryCode: event.countryCode, height: 32)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text(event.countryName)
                                .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                            Text(event.description)
                                .font(DesignSystem.Font.system(size: 22))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(event.year)")
                                .font(DesignSystem.Font.system(size: 20, weight: .bold))
                                .foregroundStyle(DesignSystem.Color.accent)

                            if !event.independenceFrom.isEmpty {
                                Text("from \(event.independenceFrom)")
                                    .font(DesignSystem.Font.system(size: 22))
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
