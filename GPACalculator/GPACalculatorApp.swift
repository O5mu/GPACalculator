import SwiftUI

@main
struct GPACalculatorApp: App {
    @State private var store = GPAStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
