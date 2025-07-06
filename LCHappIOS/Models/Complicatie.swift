struct Complicatie: Codable, Identifiable {
    let Code: String
    let SHcode: String             
    let Actief: Bool
    var SnmValide: Bool?
    var LastUpdate: String?
    var CxTekst: String
    var CxTekst_zoek: String
    var Inclusietermen: String
    var Exclusietermen: String
    var Definitie: String?
    var Commentaar: String?
    var Snomed: String?
    var CxTekst_ACCESS: String?
    var GRPtekst: String?
    var SRTtekst: String?
    var SPCtekst: String?
    var LOCtekst: String?

    var id: String { Code }
}



