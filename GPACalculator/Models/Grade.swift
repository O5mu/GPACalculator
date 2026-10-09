import SwiftUI

/// The grading scale a university uses.
enum GradeScale: Int, CaseIterable, Codable, Identifiable {
    case four = 4
    case five = 5

    var id: Int { rawValue }

    var maximum: Double { Double(rawValue) }

    var title: LocalizedStringResource { "Out of \(String(rawValue))" }

    /// Sensible default: Saudi universities mostly use the 5 point scale.
    static var regionalDefault: GradeScale {
        Locale.current.region?.identifier == "SA" ? .five : .four
    }
}

/// Letter grades following the common Saudi university grading system.
enum Grade: String, CaseIterable, Codable, Identifiable {
    case aPlus = "A+"
    case a = "A"
    case bPlus = "B+"
    case b = "B"
    case cPlus = "C+"
    case c = "C"
    case dPlus = "D+"
    case d = "D"
    case f = "F"

    var id: String { rawValue }

    /// Letter grades are always shown in English, in every language.
    var letter: String { rawValue }

    /// Grade points on the requested scale. The 5 point scale is the 4 point scale plus one,
    /// so an F counts as 1.0 out of 5 and 0.0 out of 4.
    func points(on scale: GradeScale) -> Double {
        switch scale {
        case .four: fourScalePoints
        case .five: fourScalePoints + 1
        }
    }

    private var fourScalePoints: Double {
        switch self {
        case .aPlus: 4.0
        case .a: 3.75
        case .bPlus: 3.5
        case .b: 3.0
        case .cPlus: 2.5
        case .c: 2.0
        case .dPlus: 1.5
        case .d: 1.0
        case .f: 0.0
        }
    }

    var color: Color {
        switch self {
        case .aPlus, .a: .green
        case .bPlus, .b: .blue
        case .cPlus, .c: .orange
        case .dPlus, .d: .pink
        case .f: .red
        }
    }
}

/// Academic standing for a GPA value.
enum Standing {
    case excellent, veryGood, good, pass, warning

    init(gpa: Double, scale: GradeScale) {
        let rounded = (gpa * 100).rounded() / 100
        let thresholds: [Double] = scale == .five ? [4.5, 3.75, 2.75, 2.0] : [3.5, 2.75, 1.75, 1.0]
        switch rounded {
        case thresholds[0]...: self = .excellent
        case thresholds[1]...: self = .veryGood
        case thresholds[2]...: self = .good
        case thresholds[3]...: self = .pass
        default: self = .warning
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .excellent: "Excellent"
        case .veryGood: "Very Good"
        case .good: "Good"
        case .pass: "Pass"
        case .warning: "Academic Warning"
        }
    }

    var symbol: String {
        switch self {
        case .excellent: "star.fill"
        case .veryGood: "hand.thumbsup.fill"
        case .good: "checkmark.circle.fill"
        case .pass: "minus.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .excellent: .green
        case .veryGood: .blue
        case .good: .teal
        case .pass: .orange
        case .warning: .red
        }
    }
}
