import Foundation

extension Locale {
    /// The app's language with Western digits (0-9) and a "." decimal separator,
    /// so numbers look the same in English and Arabic.
    static let app: Locale = {
        let language = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale(identifier: "\(language)@numbers=latn")
    }()
}
