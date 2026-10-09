# معدّلي (GPA Calculator)

A simple GPA calculator for university students, built with SwiftUI and the iOS 26 Liquid Glass design.

## Features

- Semester GPA with a live progress ring and academic standing (Excellent, Very Good, Good, Pass)
- 4 point and 5 point grading scales, switchable at any time
- Optional cumulative GPA from your previous record (completed hours and current GPA)
- Goal planner: pick a target GPA and your upcoming hours to see the average and letter grade you need, plus what each grade would bring your cumulative GPA to
- English and Arabic (the app is named معدّلي in both languages), with full right to left layout; numbers and letter grades stay in English in both languages
- Light and dark mode, Dynamic Type, VoiceOver labels and haptics
- Courses are saved on the device automatically

## Grade points

| Grade | Out of 4 | Out of 5 |
|-------|----------|----------|
| A+    | 4.00     | 5.00     |
| A     | 3.75     | 4.75     |
| B+    | 3.50     | 4.50     |
| B     | 3.00     | 4.00     |
| C+    | 2.50     | 3.50     |
| C     | 2.00     | 3.00     |
| D+    | 1.50     | 2.50     |
| D     | 1.00     | 2.00     |
| F     | 0.00     | 1.00     |

## Requirements

- Xcode 26 or later
- iOS 26 or later

## Running

1. Open `GPACalculator.xcodeproj` in Xcode.
2. Select the GPACalculator target, then under Signing & Capabilities choose your team.
3. Pick an iPhone simulator or your device and press Run.

To test Arabic, edit the scheme (Product > Scheme > Edit Scheme > Run > Options) and set App Language to Arabic, or change the language for the app in the iOS Settings app.

## License

MIT. See [LICENSE](LICENSE).
