import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(GPAStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var creditsText = ""
    @State private var gpaText = ""
    @State private var isConfirmingClear = false

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            Form {
                Section {
                    Picker("Grading Scale", selection: $store.scale) {
                        ForEach(GradeScale.allCases) { scale in
                            Text(scale.title).tag(scale)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Grading Scale")
                } footer: {
                    Text("Choose the scale your university uses.")
                }

                Section {
                    LabeledContent("Completed Hours") {
                        TextField("Hours", text: $creditsText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Cumulative GPA") {
                        TextField("GPA", text: $gpaText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Previous Semesters")
                } footer: {
                    Text("Enter your current cumulative GPA and completed hours to see your new cumulative GPA.")
                }

                Section("Grade Points") {
                    ForEach(Grade.allCases) { grade in
                        LabeledContent {
                            Text(grade.points(on: store.scale), format: .number.precision(.fractionLength(2)))
                                .monospacedDigit()
                        } label: {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(grade.color.gradient)
                                    .frame(width: 10, height: 10)
                                Text(grade.letter)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }

                Section {
                    Button("Change Language", systemImage: "globe") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                } header: {
                    Text("Language")
                } footer: {
                    Text("Choose English or Arabic for this app in Settings.")
                }

                Section {
                    Button("Remove All Courses", systemImage: "trash", role: .destructive) {
                        isConfirmingClear = true
                    }
                    .disabled(store.courses.isEmpty)
                    .confirmationDialog("Remove all courses?", isPresented: $isConfirmingClear, titleVisibility: .visible) {
                        Button("Remove All Courses", role: .destructive) {
                            withAnimation { store.courses.removeAll() }
                        }
                    } message: {
                        Text("This can't be undone.")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .onAppear {
                creditsText = store.previousCredits > 0 ? NumberParser.format(Double(store.previousCredits), fraction: 0) : ""
                gpaText = store.previousGPA > 0 ? NumberParser.format(store.previousGPA, fraction: 2) : ""
            }
            .onChange(of: creditsText) {
                let credits = min(max(NumberParser.parse(creditsText) ?? 0, 0), 999)
                store.previousCredits = Int(credits)
            }
            .onChange(of: gpaText) {
                store.previousGPA = min(max(NumberParser.parse(gpaText) ?? 0, 0), store.scale.maximum)
            }
        }
    }
}

/// Parses numbers typed with either Western or Arabic digits and separators.
enum NumberParser {
    private static let localFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter
    }()

    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let number = localFormatter.number(from: trimmed) {
            return number.doubleValue
        }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    static func format(_ value: Double, fraction: Int) -> String {
        value.formatted(.number.precision(.fractionLength(0...fraction)).grouping(.never))
    }
}
