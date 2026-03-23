import SwiftUI

struct DistanceCalculatorScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var countryDataService = CountryDataService()
    @Environment(TabCoordinator.self) private var coordinator

    @State private var originCountry: Country?
    @State private var destinationCountry: Country?
    @State private var showOriginPicker = false
    @State private var showDestinationPicker = false
    @State private var lineProgress: CGFloat = 0
    @State private var blobAnimating = false

    var body: some View {
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
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Distance Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton()
            }
        }
        .task { countryDataService.loadCountries() }
        .sheet(isPresented: $showOriginPicker) {
            CountryPickerSheet(
                title: "From Country",
                countries: countryDataService.countries
            ) { country in
                hapticsService.selection()
                originCountry = country
                animateLine()
            }
        }
        .sheet(isPresented: $showDestinationPicker) {
            CountryPickerSheet(
                title: "To Country",
                countries: countryDataService.countries
            ) { country in
                hapticsService.selection()
                destinationCountry = country
                animateLine()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }
}

// MARK: - Subviews

private extension DistanceCalculatorScreen {
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
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(color)
                    .frame(width: 24)

                if let country {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        FlagView(countryCode: country.code, height: 20)
                        Text(country.name)
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Spacer()
                        Text(country.capital)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                } else {
                    Text(placeholder)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var swapButton: some View {
        HStack {
            Spacer()
            Button {
                hapticsService.impact(.light)
                let temp = originCountry
                originCountry = destinationCountry
                destinationCountry = temp
                animateLine()
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.accent)
                    .background(DesignSystem.Color.background, in: Circle())
            }
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

                HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                    Text(formatDistance(distance, inKm: true))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(DesignSystem.Color.accent)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4), value: distance)

                    Text("km")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

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
    }

    func comparisonsSection(distance: Double) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("In perspective")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)

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
                    .font(.system(size: 22))
                    .frame(width: 32)

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
        }
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.20), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -80)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 400)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
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
        let earthRadius = 6371.0
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

// MARK: - Distance Map View

private struct DistanceMapView: View {
    let originCode: String?
    let destinationCode: String?
    let lineProgress: CGFloat

    var body: some View {
        Canvas { context, size in
            drawBackground(in: context, size: size)
            if let origin = originCoordinate, let destination = destinationCoordinate {
                drawLine(in: context, size: size, from: origin, to: destination)
                drawDot(
                    in: context, size: size,
                    coordinate: origin,
                    color: DesignSystem.Color.accent,
                    label: originCode ?? ""
                )
                drawDot(
                    in: context, size: size,
                    coordinate: destination,
                    color: DesignSystem.Color.error,
                    label: destinationCode ?? ""
                )
            }
        }
        .background(DesignSystem.Color.cardBackground)
    }

    private func mapPoint(from coordinate: CapitalCoordinateService.Coordinate, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 20
        let usableWidth = size.width - padding * 2
        let usableHeight = size.height - padding * 2
        let x = padding + CGFloat((coordinate.longitude + 180) / 360) * usableWidth
        let y = padding + CGFloat((90 - coordinate.latitude) / 180) * usableHeight
        return CGPoint(x: x, y: y)
    }

    private func drawBackground(in context: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(Path(rect), with: .color(DesignSystem.Color.cardBackground))

        var gridContext = context
        gridContext.opacity = 0.06
        for i in stride(from: 0, through: 6, by: 1) {
            let x = CGFloat(i) / 6.0 * size.width
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            gridContext.stroke(path, with: .color(DesignSystem.Color.textPrimary), lineWidth: 0.5)
        }
        for i in stride(from: 0, through: 4, by: 1) {
            let y = CGFloat(i) / 4.0 * size.height
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            gridContext.stroke(path, with: .color(DesignSystem.Color.textPrimary), lineWidth: 0.5)
        }
    }

    private func drawLine(
        in context: GraphicsContext,
        size: CGSize,
        from origin: CapitalCoordinateService.Coordinate,
        to destination: CapitalCoordinateService.Coordinate
    ) {
        let startPoint = mapPoint(from: origin, in: size)
        let endPoint = mapPoint(from: destination, in: size)
        let currentEnd = CGPoint(
            x: startPoint.x + (endPoint.x - startPoint.x) * lineProgress,
            y: startPoint.y + (endPoint.y - startPoint.y) * lineProgress
        )

        let midX = (startPoint.x + endPoint.x) / 2
        let midY = min(startPoint.y, endPoint.y) - 40
        let controlPoint = CGPoint(x: midX, y: midY)

        var path = Path()
        path.move(to: startPoint)
        path.addQuadCurve(to: currentEnd, control: controlPoint)

        var shadowContext = context
        shadowContext.opacity = 0.3
        shadowContext.stroke(path, with: .color(DesignSystem.Color.accent), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        context.stroke(path, with: .color(DesignSystem.Color.accent), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4]))
    }

    private func drawDot(
        in context: GraphicsContext,
        size: CGSize,
        coordinate: CapitalCoordinateService.Coordinate,
        color: Color,
        label: String
    ) {
        let point = mapPoint(from: coordinate, in: size)
        let dotSize: CGFloat = 10
        let dotRect = CGRect(
            x: point.x - dotSize / 2,
            y: point.y - dotSize / 2,
            width: dotSize,
            height: dotSize
        )

        context.fill(Path(ellipseIn: dotRect), with: .color(color))
        context.fill(
            Path(ellipseIn: dotRect.insetBy(dx: 3, dy: 3)),
            with: .color(.white)
        )
    }

    private var originCoordinate: CapitalCoordinateService.Coordinate? {
        guard let code = originCode else { return nil }
        return CapitalCoordinateService.coordinate(for: code)
    }

    private var destinationCoordinate: CapitalCoordinateService.Coordinate? {
        guard let code = destinationCode else { return nil }
        return CapitalCoordinateService.coordinate(for: code)
    }
}

// MARK: - Country Picker Sheet

private struct CountryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let countries: [Country]
    let onSelect: (Country) -> Void

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    onSelect(country)
                    dismiss()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        FlagView(countryCode: country.code, height: 24)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text(country.name)
                                .font(DesignSystem.Font.body)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Text(country.capital)
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries…")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var filteredCountries: [Country] {
        let all = countries
        guard !searchText.isEmpty else { return all }
        let query = searchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(query) ||
            $0.capital.lowercased().contains(query)
        }
    }
}
