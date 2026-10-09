import SwiftUI

/// A soft mesh gradient behind the content so Liquid Glass has something to refract.
struct AmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.6, 0.45], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: colorScheme == .dark ? darkColors : lightColors
        )
        .ignoresSafeArea()
    }

    private var lightColors: [Color] {
        [
            Color(red: 0.80, green: 0.87, blue: 1.00), Color(red: 0.90, green: 0.85, blue: 1.00), Color(red: 0.98, green: 0.88, blue: 0.95),
            Color(red: 0.85, green: 0.95, blue: 0.98), Color(red: 0.95, green: 0.95, blue: 1.00), Color(red: 0.88, green: 0.86, blue: 1.00),
            Color(red: 0.82, green: 0.95, blue: 0.92), Color(red: 0.86, green: 0.90, blue: 1.00), Color(red: 0.93, green: 0.87, blue: 1.00)
        ]
    }

    private var darkColors: [Color] {
        [
            Color(red: 0.05, green: 0.07, blue: 0.20), Color(red: 0.15, green: 0.08, blue: 0.30), Color(red: 0.25, green: 0.07, blue: 0.25),
            Color(red: 0.03, green: 0.15, blue: 0.22), Color(red: 0.06, green: 0.06, blue: 0.14), Color(red: 0.12, green: 0.10, blue: 0.30),
            Color(red: 0.02, green: 0.18, blue: 0.18), Color(red: 0.06, green: 0.10, blue: 0.25), Color(red: 0.14, green: 0.06, blue: 0.22)
        ]
    }
}
