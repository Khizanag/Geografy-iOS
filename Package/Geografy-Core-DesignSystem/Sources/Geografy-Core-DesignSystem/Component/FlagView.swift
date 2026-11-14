import Geografy_Core_Common
import SwiftUI

public struct FlagView: View {
    // MARK: - Properties
    @Environment(\.displayScale) private var displayScale
    @Environment(\.locale) private var locale

    @State private var loaded: LoadedFlag?

    let countryCode: String
    var height: CGFloat = DesignSystem.Size.md
    var fixedWidth: Bool = false
    var isOutlined: Bool = false

    // MARK: - Init
    /// - Parameter isOutlined: Edges the flag with a hairline, so white and pale flags stand off the background.
    ///   Use it in place of a drop shadow on flags that repeat in scrolling lists:
    ///   a shadow costs an offscreen render pass per flag.
    public init(
        countryCode: String,
        height: CGFloat = DesignSystem.Size.md,
        fixedWidth: Bool = false,
        isOutlined: Bool = false
    ) {
        self.countryCode = countryCode
        self.height = height
        self.fixedWidth = fixedWidth
        self.isOutlined = isOutlined
    }

    // MARK: - Body
    public var body: some View {
        flagImage
            .clipShape(Self.flagShape)
            .frame(width: fixedWidth ? slotWidth : nil, height: fixedWidth ? height : nil, alignment: .center)
            .accessibilityLabel("Flag of \(FlagImageCache.shared.countryName(for: countryCode, in: locale))")
            .task(id: loadKey) { await load() }
    }
}

// MARK: - Loaded Flag
private extension FlagView {
    /// The image decoded for one code and size; a nil image means the app has no flag for that code.
    struct LoadedFlag {
        let key: String
        let image: UIImage?
    }
}

// MARK: - Subviews
private extension FlagView {
    @ViewBuilder
    var flagImage: some View {
        let image = currentImage
        let size = fittedSize(ratio: FlagAspectRatio.ratio(for: countryCode) ?? image.map(aspectRatio) ?? 4 / 3)

        if let image {
            Image(uiImage: image)
                .resizable()
                .frame(width: size.width, height: size.height)
                .overlay {
                    if isOutlined {
                        Self.flagShape.strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 0.5)
                    }
                }
        } else if loaded?.key == loadKey {
            Text(fallbackEmoji)
                .font(DesignSystem.Font.title)
        } else {
            // Holds the flag's place for the moment it takes to decode, so nothing around it shifts.
            DesignSystem.Color.cardBackgroundHighlighted
                .frame(width: size.width, height: size.height)
        }
    }

    static let flagShape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2, style: .continuous)

    /// The width reserved for each flag when `fixedWidth` is on, so a list's text lines up.
    var slotWidth: CGFloat { height * 1.6 }

    // A fixed-width slot fits wide flags (2:1 and wider) to its width instead of letting them
    // spill past it; flags that fit keep the full height.
    func fittedSize(ratio: CGFloat) -> CGSize {
        let naturalWidth = height * ratio
        guard fixedWidth, naturalWidth > slotWidth else {
            return CGSize(width: naturalWidth, height: height)
        }
        return CGSize(width: slotWidth, height: slotWidth / ratio)
    }

    var pixelHeight: CGFloat { height * displayScale }

    var loadKey: String { "\(countryCode)-\(Int(pixelHeight))" }

    /// Taken from the cache first, so a flag already decoded draws in the first frame.
    var currentImage: UIImage? {
        FlagImageCache.shared.cachedImage(countryCode: countryCode, pixelHeight: pixelHeight)
            ?? (loaded?.key == loadKey ? loaded?.image : nil)
    }

    func aspectRatio(of image: UIImage) -> CGFloat {
        image.size.width / image.size.height
    }

    func load() async {
        let key = loadKey
        guard FlagImageCache.shared.cachedImage(countryCode: countryCode, pixelHeight: pixelHeight) == nil else {
            return
        }
        let image = await FlagImageCache.shared.image(countryCode: countryCode, pixelHeight: pixelHeight)
        guard !Task.isCancelled else { return }
        loaded = LoadedFlag(key: key, image: image)
    }

    var fallbackEmoji: String {
        countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(127_397 + $0.value) }
            .map { String($0) }
            .joined()
    }
}
