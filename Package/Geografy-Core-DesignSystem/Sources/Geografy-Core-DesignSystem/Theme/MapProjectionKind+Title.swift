import Geografy_Core_Common
import SwiftUI

public extension MapProjectionKind {
    var title: LocalizedStringKey {
        switch self {
        case .mercator: "Mercator"
        case .equalEarth: "Equal Earth"
        }
    }
}
