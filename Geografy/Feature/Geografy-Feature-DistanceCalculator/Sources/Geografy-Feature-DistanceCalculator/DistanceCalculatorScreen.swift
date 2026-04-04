import Geografy_Core_Navigation
#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct DistanceCalculatorScreen: View {
    public init() {}
    @Environment(CountryDataService.self) private var countryDataService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(Navigator.self) private var coordinator

    @State private var originCountry: Country?
    @State private var destinationCountry: Country?
    @State private var showOriginPicker = false
    @State private var showDestinationPicker = false
    @State private var lineProgress: CGFloat = 0

    public var body: some View {
        extractedContent
            .background { AmbientBlobsView(.standard) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Distance Calculator")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showOriginPicker) {
                DistanceCountryPickerSheet(
                    title: "From Country",
                    countries: countryDataService.countries
                ) { country in
                    #if !os(tvOS)
                    hapticsService.selection()
                    #endif
                    originCountry = country
                    animateLine()
                }
            }
            .sheet(isPresented: $showDestinationPicker) {
                DistanceCountryPickerSheet(
                    title: "To Country",
                    countries: countryDataService.countries
                ) { country in
                    #if !os(tvOS)
                    hapticsService.selection()
                    #endif
                    destinationCountry = country
                    animateLine()
                }
            }
    }
}

// MARK: - Subviews
private extension DistanceCalculatorScreen {
    var extractedContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                pickerSection
                if let distance = calculatedDistance {
                    distanceSection(distance: distance)
                    miniMapSection
                    comparisonsSection(distance: distance)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var pickerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            originPicker
            swapButton
            destinationPicker
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var originPicker: some View {
        countryPickerButton(
            country: originCountry,
            placeholder: "Select origin country",
            icon: "location.fill",
            color: DesignSystem.Color.accent
        ) {
            showOriginPicker = true
        }
    }

    var destinationPicker: some View {
        countryPickerButton(
            country: destinationCountry,
            placeholder: "Select destination country",
            icon: "mappin.and.ellipse",
            color: DesignSystem.Color.error
        ) {
            showDestinationPicker = true
        }
    }

    func countryPickerButton(
        country: Country?,
        placeholder: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            countryPickerButtonLabel(
                country: country,
                placeholder: placeholder,
                icon: icon,
                color: color
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    @ViewBuilder
    func countryPickerButtonLabel(
        country: Country?,
        placeholder: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.body)
                .foregroundStyle(color)
                .frame(width: 24)

            if let country {
                selectedCountryRow(country)
            } else {
                placeholderRow(placeholder)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(color.opacity(0.25), lineWidth: 1)
        )
    }

    func selectedCountryRow(_ country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: country.code, height: 20, fixedWidth: true)
            Text(country.name)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Text(country.capital)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func placeholderRow(_ placeholder: String) -> some View {
        HStack {
            Text(placeholder)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Spacer()
            Image(systemName: "chevron.down")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var swapButton: some View {
        let hasCountry = originCountry != nil || destinationCountry != nil
        return HStack {
            Spacer()
            Button {
                #if !os(tvOS)
                hapticsService.impact(.light)
                #endif
                let temp = originCountry
                originCountry = destinationCountry
                destinationCountry = temp
                animateLine()
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(hasCountry ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
                    .background(DesignSystem.Color.background, in: Circle())
            }
            .disabled(!hasCountry)
            Spacer()
        }
    }

    func distanceSection(distance: Double) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Great Circle Distance")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .textCase(.uppercase)
                    .accessibilityAddTraits(.isHeader)

                HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                    Text(formatDistance(distance, inKm: true))
                        .font(DesignSystem.Font.roundedLarge)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4), value: distance)

                    Text("km")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(formatDistance(distance, inKm: true)) kilometers")

                Text("\(formatDistance(distance * 0.621371, inKm: false)) miles")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: distance)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.lg)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var miniMapSection: some View {
        CardView {
            DistanceMapView(
                originCode: originCountry?.code,
                destinationCode: destinationCountry?.code,
                lineProgress: lineProgress
            )
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .accessibilityLabel("Map showing route between selected countries")
    }

    func comparisonsSection(distance: Double) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("In perspective")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(comparisons(for: distance), id: \.label) { item in
                    comparisonRow(icon: item.icon, label: item.label, value: item.value)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func comparisonRow(icon: String, label: String, value: String) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(icon)
                    .font(DesignSystem.Font.iconDefault)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                Text(label)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Spacer()

                Text(value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(DesignSystem.Spacing.sm)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(label): \(value)")
        }
    }
}

// MARK: - Actions
private extension DistanceCalculatorScreen {
    func animateLine() {
        guard originCountry != nil, destinationCountry != nil else { return }
        lineProgress = 0
        withAnimation(.easeInOut(duration: 1.2)) {
            lineProgress = 1
        }
    }
}

// MARK: - Helpers
private extension DistanceCalculatorScreen {
    var calculatedDistance: Double? {
        guard
            let origin = originCountry,
            let destination = destinationCountry,
            let originCoord = CapitalCoordinateService.coordinate(for: origin.code),
            let destCoord = CapitalCoordinateService.coordinate(for: destination.code)
        else { return nil }

        return haversineDistance(
            lat1: originCoord.latitude,
            lon1: originCoord.longitude,
            lat2: destCoord.latitude,
            lon2: destCoord.longitude
        )
    }

    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6_371.0
        let deltaLat = (lat2 - lat1) * .pi / 180
        let deltaLon = (lon2 - lon1) * .pi / 180
        let sinLat = sin(deltaLat / 2)
        let sinLon = sin(deltaLon / 2)
        let alpha = sinLat * sinLat +
            cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sinLon * sinLon
        let centralAngle = 2 * atan2(sqrt(alpha), sqrt(1 - alpha))
        return earthRadius * centralAngle
    }

    func formatDistance(_ value: Double, inKm: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    struct ComparisonItem {
        let icon: String
        let label: String
        let value: String
    }

    func comparisons(for distanceKm: Double) -> [ComparisonItem] {
        let earthCircumference = 40_075.0
        let planeSpeedKmh = 900.0
        let lightSpeedKmPerMs = 299.792

        let earthLaps = distanceKm / earthCircumference
        let flightHours = distanceKm / planeSpeedKmh
        let lightMs = distanceKm / lightSpeedKmPerMs

        let earthLapsText = earthLaps < 1
            ? String(format: "%.1f%% of Earth's circumference", earthLaps * 100)
            : String(format: "%.1f× around Earth", earthLaps)

        let flightText: String
        if flightHours < 1 {
            flightText = String(format: "~%.0f min by plane", flightHours * 60)
        } else {
            flightText = String(format: "~%.1f hours by plane", flightHours)
        }

        let lightText = String(format: "%.1f milliseconds at light speed", lightMs)

        return [
            ComparisonItem(icon: "🌍", label: "Earth's size", value: earthLapsText),
            ComparisonItem(icon: "✈️", label: "Flight time", value: flightText),
            ComparisonItem(icon: "⚡️", label: "Light speed", value: lightText),
        ]
    }
}
#endif
