import SwiftUI

struct ContentView: View {
    @Environment(GPAStore.self) private var store
    @State private var activeSheet: ActiveSheet?
    @State private var isShowingPlanner = false

    private enum ActiveSheet: Identifiable {
        case newCourse
        case edit(Course)
        case settings

        var id: String {
            switch self {
            case .newCourse: "new"
            case .edit(let course): "edit-\(course.id)"
            case .settings: "settings"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                GPAHeroCard()
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                    .glassRow()

                Button {
                    isShowingPlanner = true
                } label: {
                    GoalPlannerRow()
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
                .glassRow()

                if store.courses.isEmpty {
                    emptyState
                        .glassRow()
                } else {
                    coursesHeader
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 4, trailing: 24))
                        .glassRow()

                    ForEach(store.courses) { course in
                        Button {
                            activeSheet = .edit(course)
                        } label: {
                            CourseRow(course: course, scale: store.scale)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        .glassRow()
                    }
                    .onDelete { offsets in
                        withAnimation { store.courses.remove(atOffsets: offsets) }
                    }
                    .onMove { source, destination in
                        store.courses.move(fromOffsets: source, toOffset: destination)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background { AmbientBackground() }
            .navigationTitle("GPA Calculator")
            // Bottom bar keeps the main actions within thumb reach.
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Settings", systemImage: "gearshape") {
                        activeSheet = .settings
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        activeSheet = .newCourse
                    } label: {
                        Label("Add Course", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .navigationDestination(isPresented: $isShowingPlanner) {
                GoalPlannerView()
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .newCourse: CourseEditorView(course: nil)
                case .edit(let course): CourseEditorView(course: course)
                case .settings: SettingsView()
                }
            }
        }
    }

    private var coursesHeader: some View {
        HStack {
            Text("Courses")
                .font(.title3.weight(.semibold))
            Spacer()
            Text(store.courses.count, format: .number)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Courses Yet", systemImage: "graduationcap")
        } description: {
            Text("Add your courses and grades to calculate your GPA.")
        } actions: {
            Button("Add Course", systemImage: "plus") {
                activeSheet = .newCourse
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

/// Entry card for the goal planner, showing the saved target at a glance.
private struct GoalPlannerRow: View {
    @Environment(GPAStore.self) private var store

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "target")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Color.accentColor.gradient, in: .circle)

            VStack(alignment: .leading, spacing: 3) {
                Text("Goal Planner")
                    .font(.headline)
                if store.targetGPA != nil {
                    Text("Target \(store.goalTarget.formatted(.number.precision(.fractionLength(2)).locale(.app)))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("See what you need to reach your target GPA.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.forward")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .contentShape(.rect(cornerRadius: 26))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 26))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

private extension View {
    /// Clears the default list chrome so the ambient background and glass show through.
    func glassRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

#Preview {
    ContentView()
        .environment(GPAStore(defaults: UserDefaults(suiteName: "preview")!))
}
