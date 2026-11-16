import CoreGraphics
import Geografy_Core_Common
import Geografy_Core_Map
import SwiftUI

/// Where the Pin Drop map sits on screen: converting between map and screen points, and framing a region.
///
/// The math matches `MapCanvasView`: a map point lands at its position times the scale, plus the
/// origin that centers the map in the view and shifts it by the offset.
enum PinDropCamera {
    static func screenPoint(of mapPoint: CGPoint, frame: MapFrame, in size: CGSize) -> CGPoint {
        let origin = origin(of: frame, in: size)
        return CGPoint(x: origin.x + mapPoint.x * frame.scale, y: origin.y + mapPoint.y * frame.scale)
    }

    static func mapPoint(of screenPoint: CGPoint, frame: MapFrame, in size: CGSize) -> CGPoint {
        let origin = origin(of: frame, in: size)
        return CGPoint(x: (screenPoint.x - origin.x) / frame.scale, y: (screenPoint.y - origin.y) / frame.scale)
    }

    /// The frame that shows `rect` as large as fits between the insets, centered in the space left.
    /// - Parameter fill: The share of that space the rect takes, leaving a margin around it.
    static func frame(fitting rect: CGRect, in size: CGSize, insets: EdgeInsets, fill: CGFloat = 0.9) -> MapFrame {
        let available = CGSize(
            width: max(size.width - insets.leading - insets.trailing, 1),
            height: max(size.height - insets.top - insets.bottom, 1)
        )
        let scale = min(available.width / max(rect.width, 1), available.height / max(rect.height, 1)) * fill
        let visibleCenter = CGPoint(
            x: insets.leading + available.width / 2,
            y: insets.top + available.height / 2
        )
        // Solve screenPoint(of: rect's center) == visibleCenter for the offset.
        let offset = CGSize(
            width: visibleCenter.x - size.width / 2 + MapProjection.mapWidth * scale / 2 - rect.midX * scale,
            height: visibleCenter.y - size.height / 2 + MapProjection.mapHeight * scale / 2 - rect.midY * scale
        )
        return MapFrame(scale: scale, offset: offset)
    }

    /// `frame` moved back so the region's center stays on screen, so a pan can't lose the map.
    static func clamped(_ frame: MapFrame, keeping rect: CGRect, in size: CGSize) -> MapFrame {
        let center = screenPoint(of: CGPoint(x: rect.midX, y: rect.midY), frame: frame, in: size)
        var clamped = frame
        clamped.offset.width += min(max(center.x, 0), size.width) - center.x
        clamped.offset.height += min(max(center.y, 0), size.height) - center.y
        return clamped
    }
}

// MARK: - Helpers
private extension PinDropCamera {
    static func origin(of frame: MapFrame, in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width / 2 - MapProjection.mapWidth * frame.scale / 2 + frame.offset.width,
            y: size.height / 2 - MapProjection.mapHeight * frame.scale / 2 + frame.offset.height
        )
    }
}
