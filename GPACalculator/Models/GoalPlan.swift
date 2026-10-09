import Foundation

/// Works out what average a student needs in their upcoming hours to reach a target cumulative GPA.
struct GoalPlan {
    let completedCredits: Int
    let completedPoints: Double
    let target: Double
    let plannedCredits: Int
    let scale: GradeScale

    enum Outcome: Equatable {
        /// The target is met even with the lowest possible grades.
        case secured
        /// Reachable by averaging at least this grade.
        case achievable(Grade)
        /// Not reachable even with top grades.
        case outOfReach
    }

    private static let tolerance = 0.0001

    private var totalCredits: Double { Double(completedCredits + plannedCredits) }

    /// The grade point average needed across the planned hours.
    var requiredAverage: Double {
        (target * totalCredits - completedPoints) / Double(plannedCredits)
    }

    /// Required average rounded up to two decimals so following it never falls short.
    var displayedRequiredAverage: Double {
        ((requiredAverage - Self.tolerance) * 100).rounded(.up) / 100
    }

    var outcome: Outcome {
        let required = requiredAverage
        if required <= Grade.f.points(on: scale) + Self.tolerance {
            return .secured
        }
        if required > scale.maximum + Self.tolerance {
            return .outOfReach
        }
        let grade = Grade.allCases.reversed().first { $0.points(on: scale) >= required - Self.tolerance } ?? .aPlus
        return .achievable(grade)
    }

    /// Cumulative GPA after the planned hours if they average the given grade points.
    func projectedGPA(averaging points: Double) -> Double {
        (completedPoints + points * Double(plannedCredits)) / totalCredits
    }

    var highestReachable: Double { projectedGPA(averaging: scale.maximum) }

    func meetsTarget(averaging grade: Grade) -> Bool {
        projectedGPA(averaging: grade.points(on: scale)) >= target - Self.tolerance
    }
}
