import Foundation

struct Course: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var credits: Int
    var grade: Grade

    static func blank() -> Course {
        Course(name: "", credits: 3, grade: .a)
    }
}
