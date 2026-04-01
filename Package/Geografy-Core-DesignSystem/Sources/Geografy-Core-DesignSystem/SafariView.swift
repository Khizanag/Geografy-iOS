#if !os(tvOS)
import SafariServices
import SwiftUI

public struct SafariView: UIViewControllerRepresentable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: configuration)
        return controller
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
