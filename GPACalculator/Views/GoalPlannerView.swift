import SwiftUI

/// Shows what average the student needs in their upcoming hours to hit a target cumulative GPA.
struct GoalPlannerView: View {
    @Environment(GPAStore.self) private var store

    private let hourPresets = [15, 30, 60]

    var body: some View {
        let plan = store.goalPlan

        ScrollView {
            GlassEffectContainer(spacing: 16) {
                VStack(spacing: 16) {
                    ResultCard(plan: plan)
                    targetCard
                    hoursCard
                    ScenariosCard(plan: plan)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .animation(.smooth, value: plan.outcome)
        }
        .scrollDismissesKeyboard(.interactively)
        .background { AmbientBackground() }
        .navigationTitle("Goal Planner")
    }

    // MARK: - Target

    private var targetBinding: Binding<Double> {
        Binding {
            store.goalTarget
        } set: { newValue in
            store.targetGPA = (newValue * 100).rounded() / 100
        }
    }

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Target GPA")
                    .font(.headline)
                Spacer()
                Text(store.goalTarget, format: .number.precision(.fractionLength(2)))
                    .font(.title.weight(.bold))
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: store.goalTarget))
            }

            Slider(value: targetBinding, in: Grade.f.points(on: store.scale)...store.scale.maximum, step: 0.01) {
                Text("Target GPA")
            } minimumValueLabel: {
                Text(Grade.f.points(on: store.scale), format: .number.precision(.fractionLength(0)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(store.scale.maximum, format: .number.precision(.fractionLength(0)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .sensoryFeedback(.selection, trigger: (store.goalTarget * 20).rounded())

            Divider()

            HStack(spacing: 0) {
                StatItem(title: "Current GPA") {
                    if let gpa = store.completedGPA {
                        Text(gpa, format: .number.precision(.fractionLength(2)))
                    } else {
                        Text(0, format: .number.precision(.fractionLength(2)))
                            .foregroundStyle(.tertiary)
                    }
                }
                StatItem(title: "Completed Hours") {
                    Text(store.completedCredits, format: .number)
                }
            }

            if store.completedCredits == 0 {
                Text("Add courses or your previous record to plan from your current GPA.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }

    // MARK: - Hours

    private var hoursCard: some View {
        @Bindable var store = store

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upcoming Hours")
                        .font(.headline)
                    Text("\(store.plannedCredits) credit hours")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                Spacer()
                Stepper("Upcoming Hours", value: $store.plannedCredits, in: 1...300)
                    .labelsHidden()
            }

            HStack(spacing: 8) {
                ForEach(hourPresets, id: \.self) { hours in
                    Button {
                        withAnimation(.snappy) { store.plannedCredits = hours }
                    } label: {
                        Text(hours, format: .number)
                            .monospacedDigit()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(store.plannedCredits == hours ? Color.accentColor : Color.secondary)
                }
            }

            Text("Credit hours you plan to take before reaching your goal.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .sensoryFeedback(.selection, trigger: store.plannedCredits)
    }
}

// MARK: - Result

private struct ResultCard: View {
    let plan: GoalPlan

    var body: some View {
        VStack(spacing: 12) {
            switch plan.outcome {
            case .achievable(let grade):
                statusLabel(Text("Within Reach"), symbol: "flag.checkered", color: .blue)

                Text("You need an average of")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(plan.displayedRequiredAverage, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: plan.displayedRequiredAverage))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("in your next \(plan.plannedCredits) credit hours")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Aim for \(Text(grade.letter).bold().foregroundStyle(grade.color)) or better in every course.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(grade.color.opacity(0.12), in: .capsule)

            case .secured:
                statusLabel(Text("Goal Secured"), symbol: "checkmark.seal.fill", color: .green)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green.gradient)
                    .symbolEffect(.bounce, value: plan.outcome)
                Text("You'll stay at or above your target even with the lowest grades.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

            case .outOfReach:
                statusLabel(Text("Out of Reach"), symbol: "exclamationmark.triangle.fill", color: .red)
                Text(plan.highestReachable, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: plan.highestReachable))
                Text("is the highest you can reach in these hours, even with top grades. Try more hours or a lower target.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 36))
        .accessibilityElement(children: .combine)
    }

    private func statusLabel(_ title: Text, symbol: String, color: Color) -> some View {
        Label {
            title
        } icon: {
            Image(systemName: symbol)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15), in: .capsule)
    }
}

// MARK: - Scenarios

private struct ScenariosCard: View {
    let plan: GoalPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("If You Average")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(Grade.allCases) { grade in
                    let meets = plan.meetsTarget(averaging: grade)
                    HStack(spacing: 12) {
                        Text(grade.letter)
                            .font(.subheadline.weight(.bold))
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(grade.color.gradient, in: .circle)

                        Text(grade.points(on: plan.scale), format: .number.precision(.fractionLength(2)))
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(plan.projectedGPA(averaging: grade.points(on: plan.scale)), format: .number.precision(.fractionLength(2)))
                            .font(.headline)
                            .fontDesign(.rounded)
                            .monospacedDigit()
                            .contentTransition(.numericText())

                        Image(systemName: meets ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(meets ? AnyShapeStyle(Color.green) : AnyShapeStyle(HierarchicalShapeStyle.tertiary))
                            .font(.title3)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityValue(meets ? Text("Meets your target") : Text("Below your target"))
                }
            }

            Text("Your cumulative GPA after the upcoming hours if you average each grade.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}
