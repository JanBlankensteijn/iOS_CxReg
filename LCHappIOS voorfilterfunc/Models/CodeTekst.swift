import Foundation

struct CodeTekst: Codable, Identifiable {
    let Code: String
    let Tekst: String

    var id: String { Code }
}
