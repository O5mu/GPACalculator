import SwiftUI

struct CourseRow: View {
    let course: Course
    let scale: GradeScale

    var body: some View {
        HStack(spacing: 14) {
            Text(course.grade.letter)
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(course.grade.color.gradient, in: .circle)

            VStack(alignment: .leading, spacing: 3) {
                Group {
                    if course.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Untitled Course")
                    } else {
                        Text(course.name)
                    }
                }
                .font(.headline)
                .lineLimit(1)

                Text("\(course.credits) credit hours")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(course.grade.points(on: scale), format: .number.precision(.fractionLength(2)))
                    .font(.headline)
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("Points")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .contentShape(.rect(cornerRadius: 26))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 26))
        .accessibilityElement(children: .combine)
    }
}
