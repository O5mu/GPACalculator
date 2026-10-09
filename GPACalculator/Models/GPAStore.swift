import Foundation
import Observation

/// Holds the student's courses and settings and persists them to UserDefaults.
@Observable
final class GPAStore {
    var courses: [Course] = [] { didSet { save() } }
    var scale: GradeScale = .regionalDefault { didSet { save() } }
    var previousCredits: Int = 0 { didSet { save() } }
    var previousGPA: Double = 0 { didSet { save() } }
    var targetGPA: Double? = nil { didSet { save() } }
    var plannedCredits: Int = 15 { didSet { save() } }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let storageKey = "gpa.snapshot.v1"

    private struct Snapshot: Codable {
        var courses: [Course]
        var scale: GradeScale
        var previousCredits: Int
        var previousGPA: Double
        // Optional so data saved before the goal planner existed still decodes.
        var targetGPA: Double?
        var plannedCredits: Int?
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        courses = snapshot.courses
        scale = snapshot.scale
        previousCredits = snapshot.previousCredits
        previousGPA = snapshot.previousGPA
        targetGPA = snapshot.targetGPA
        plannedCredits = snapshot.plannedCredits ?? 15
    }

    // MARK: - Calculations

    var semesterCredits: Int {
        courses.reduce(0) { $0 + $1.credits }
    }

    var semesterPoints: Double {
        courses.reduce(0) { $0 + Double($1.credits) * $1.grade.points(on: scale) }
    }

    var semesterGPA: Double? {
        semesterCredits > 0 ? semesterPoints / Double(semesterCredits) : nil
    }

    var hasPreviousRecord: Bool { previousCredits > 0 }

    var cumulativeGPA: Double? {
        guard hasPreviousRecord else { return nil }
        return completedPoints / Double(completedCredits)
    }

    /// Previous record plus this semester's courses.
    var completedCredits: Int {
        max(previousCredits, 0) + semesterCredits
    }

    var completedPoints: Double {
        let gpa = min(max(previousGPA, 0), scale.maximum)
        return gpa * Double(max(previousCredits, 0)) + semesterPoints
    }

    var completedGPA: Double? {
        completedCredits > 0 ? completedPoints / Double(completedCredits) : nil
    }

    // MARK: - Goal

    /// The saved target clamped to the current scale, or a sensible default.
    var goalTarget: Double {
        let fallback = scale == .five ? 4.5 : 3.5
        return min(max(targetGPA ?? fallback, Grade.f.points(on: scale)), scale.maximum)
    }

    var goalPlan: GoalPlan {
        GoalPlan(
            completedCredits: completedCredits,
            completedPoints: completedPoints,
            target: goalTarget,
            plannedCredits: max(plannedCredits, 1),
            scale: scale
        )
    }

    // MARK: - Editing

    func upsert(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
        } else {
            courses.append(course)
        }
    }

    func delete(_ course: Course) {
        courses.removeAll { $0.id == course.id }
    }

    // MARK: - Persistence

    private func save() {
        let snapshot = Snapshot(
            courses: courses,
            scale: scale,
            previousCredits: previousCredits,
            previousGPA: previousGPA,
            targetGPA: targetGPA,
            plannedCredits: plannedCredits
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
