import SwiftUI

/// The main glass card showing the semester GPA, the scale picker and summary stats.
struct GPAHeroCard: View {
    @Environment(GPAStore.self) private var store

    var body: some View {
        @Bindable var store = store

        VStack(spacing: 20) {
            HStack {
                Text("Semester GPA")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let gpa = store.semesterGPA {
                    StandingBadge(standing: Standing(gpa: gpa, scale: store.scale))
                        .transition(.scale.combined(with: .opacity))
                }
            }

            GPARing(value: store.semesterGPA, scale: store.scale)
                .frame(width: 200, height: 200)

            Picker("Grading Scale", selection: $store.scale) {
                ForEach(GradeScale.allCases) { scale in
                    Text(scale.title).tag(scale)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 0) {
                StatItem(title: "Credit Hours") {
                    Text(store.semesterCredits, format: .number)
                }
                StatItem(title: "Courses") {
                    Text(store.courses.count, format: .number)
                }
                if let cumulative = store.cumulativeGPA {
                    StatItem(title: "Cumulative") {
                        Text(cumulative, format: .number.precision(.fractionLength(2)))
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 36))
        .animation(.smooth, value: store.semesterGPA)
        .animation(.smooth, value: store.scale)
        .sensoryFeedback(.selection, trigger: store.scale)
    }
}

struct GPARing: View {
    let value: Double?
    let scale: GradeScale

    private var progress: Double {
        guard let value else { return 0 }
        return min(max(value / scale.maximum, 0), 1)
    }

    private var tint: Color {
        guard let value else { return .secondary }
        return Standing(gpa: value, scale: scale).color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 18)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.35), radius: 8)

            VStack(spacing: 2) {
                Text(value ?? 0, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: value ?? 0))
                    .foregroundStyle(value == nil ? HierarchicalShapeStyle.tertiary : .primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("out of \(scale.maximum.formatted(.number.precision(.fractionLength(2))))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(28)
        }
        .animation(.smooth(duration: 0.6), value: progress)
        .accessibilityElement(children: .combine)
    }
}

private struct StandingBadge: View {
    let standing: Standing

    var body: some View {
        Label {
            Text(standing.title)
        } icon: {
            Image(systemName: standing.symbol)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(standing.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(standing.color.opacity(0.15), in: .capsule)
    }
}

struct StatItem<Value: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let value: Value

    var body: some View {
        VStack(spacing: 4) {
            value
                .font(.title3.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
