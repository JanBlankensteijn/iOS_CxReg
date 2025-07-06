import Foundation

struct LCHWrapper: Codable {
    let metadata: LCHInfo
    let data: [Complicatie]
    let GRP: [CodeTekst]?
    let SRT: [CodeTekst]?
    let SPC: [CodeTekst]?
    let LOC: [CodeTekst]?
}
