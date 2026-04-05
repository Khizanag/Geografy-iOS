import Foundation

public extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        descending: Bool
    ) -> [Element] {
        sorted {
            descending
                ? $0[keyPath: keyPath] > $1[keyPath: keyPath]
                : $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}
