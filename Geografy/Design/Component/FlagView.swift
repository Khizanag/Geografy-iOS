import SwiftUI
import PDFKit

struct FlagView: View {
    let countryCode: String
    var height: CGFloat = DesignSystem.Size.md

    var body: some View {
        flagImage
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2))
    }
}

// MARK: - Subviews

private extension FlagView {
    @ViewBuilder
    var flagImage: some View {
        if let image = Self.loadPDF(code: countryCode, height: height) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text(fallbackEmoji)
                .font(DesignSystem.Font.title)
        }
    }

    var fallbackEmoji: String {
        countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map { String($0) }
            .joined()
    }
}

// MARK: - PDF Rendering

private extension FlagView {
    static func loadPDF(code: String, height: CGFloat) -> UIImage? {
        guard let url = Bundle.main.url(
            forResource: code.uppercased(),
            withExtension: "pdf",
            subdirectory: "Flags"
        ) else { return nil }

        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else { return nil }

        let pageRect = page.bounds(for: .mediaBox)
        let scale = (height * UIScreen.main.scale) / pageRect.height
        let renderSize = CGSize(
            width: pageRect.width * scale,
            height: pageRect.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: renderSize)
        return renderer.image { context in
            UIColor.clear.set()
            context.fill(CGRect(origin: .zero, size: renderSize))

            context.cgContext.translateBy(x: 0, y: renderSize.height)
            context.cgContext.scaleBy(x: scale, y: -scale)

            page.draw(with: .mediaBox, to: context.cgContext)
        }
    }
}
