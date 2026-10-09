import SwiftUI

struct CourseEditorView: View {
    @Environment(GPAStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var course: Course
    private let isNew: Bool

    init(course: Course?) {
        _course = State(initialValue: course ?? .blank())
        isNew = course == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Course Name", text: $course.name)
                        .submitLabel(.done)

                    Stepper(value: $course.credits, in: 1...12) {
                        LabeledContent("Credit Hours") {
                            Text(course.credits, format: .number)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                    }
                    .sensoryFeedback(.selection, trigger: course.credits)
                }

                Section("Grade") {
                    GradePicker(selection: $course.grade, scale: store.scale)
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                }

                if !isNew {
                    Section {
                        Button("Delete Course", systemImage: "trash", role: .destructive) {
                            withAnimation { store.delete(course) }
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isNew ? Text("New Course") : Text("Edit Course"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        withAnimation { store.upsert(course) }
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }
}

/// A grid of glass buttons for choosing a letter grade.
struct GradePicker: View {
    @Binding var selection: Grade
    let scale: GradeScale

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Grade.allCases) { grade in
                    GradeCell(grade: grade, scale: scale, isSelected: grade == selection) {
                        withAnimation(.snappy) { selection = grade }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

private struct GradeCell: View {
    let grade: Grade
    let scale: GradeScale
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Group {
            if isSelected {
                Button(action: action) { label }
                    .buttonStyle(.glassProminent)
                    .tint(grade.color)
            } else {
                Button(action: action) { label }
                    .buttonStyle(.glass)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var label: some View {
        VStack(spacing: 2) {
            Text(grade.letter)
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
            Text(grade.points(on: scale), format: .number.precision(.fractionLength(2)))
                .font(.caption)
                .monospacedDigit()
                .opacity(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}
