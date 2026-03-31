import CoreGraphics

public extension CGPath {
    func containsPoint(_ point: CGPoint) -> Bool {
        contains(point)
    }
}
