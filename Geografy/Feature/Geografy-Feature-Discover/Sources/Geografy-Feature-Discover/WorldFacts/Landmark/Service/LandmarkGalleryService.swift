import Foundation
import Geografy_Core_Common

/// The world's landmarks, from `landmarks.json`.
public final class LandmarkGalleryService {
    public let landmarks = BundledJSON.decode([Landmark].self, named: "landmarks", in: .module) ?? []

    public init() {}

    public func landmarks(in category: LandmarkCategory?) -> [Landmark] {
        guard let category else { return landmarks }
        return landmarks.filter { $0.category == category }
    }
}
