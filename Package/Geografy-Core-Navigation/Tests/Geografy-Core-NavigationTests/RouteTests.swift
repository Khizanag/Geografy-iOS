@testable import Geografy_Core_Navigation
import SwiftUI
import Testing

@Suite("Routes")
@MainActor
struct RouteTests {
    enum SampleRoute: Route {
        case first
        case second(Int)
    }

    enum OtherRoute: Route {
        case first
    }

    @Test("Equal routes make equal destinations")
    func equalRoutesMatch() {
        #expect(Destination(SampleRoute.second(1)) == Destination(SampleRoute.second(1)))
        #expect(Destination(SampleRoute.second(1)) != Destination(SampleRoute.second(2)))
    }

    @Test("Cases with the same name in different route types stay apart")
    func routeTypesStayApart() {
        #expect(Destination(SampleRoute.first) != Destination(OtherRoute.first))
    }

    @Test("The registry draws only the route types registered with it")
    func registryKnowsRegisteredTypes() {
        var registry = RouteRegistry()
        registry.register(SampleRoute.self) { _ in Text(verbatim: "Sample") }

        #expect(registry.isRegistered(Destination(SampleRoute.second(4))))
        #expect(!registry.isRegistered(Destination(OtherRoute.first)))
    }

    @Test("The navigator pushes, presents, and dismisses routes")
    func navigatorPresentsRoutes() {
        let navigator = Navigator()

        navigator.push(SampleRoute.first)
        navigator.sheet(SampleRoute.second(3))
        navigator.cover(OtherRoute.first)
        #expect(navigator.path.count == 1)
        #expect(navigator.activeSheet == Destination(SampleRoute.second(3)))

        navigator.dismiss()
        #expect(navigator.activeCover == nil)
        #expect(navigator.activeSheet != nil)

        navigator.popToRoot()
        #expect(navigator.path.isEmpty)
    }
}
