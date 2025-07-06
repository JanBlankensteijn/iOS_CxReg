import SwiftUI

struct InfoView: View {
    @EnvironmentObject var model: LCHModel

    var body: some View {
        ScrollView {
            if let meta = model.metadata {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CompLOCaties: \(meta.AantalRecords)")
                    Text("Actieve compLOCaties: \(meta.AantalRecords - meta.NInactief)")

                    Text("Hoofdgroepen: \(meta.NGRPcodes)")
                    Text("Soorten: \(meta.NSRTcodes)")
                    Text("Specificaties: \(meta.NSPCcodes)")
                    Text("Locaties: \(meta.NLOCcodes)")

                    Group {
                        Text("Aanmaakdatum: \(formatDate(meta.Aanmaakdatum, format: "dd-MM-yyyy"))")
                        Text("Exportdatum: \(formatDate(meta.Exportdatum, format: "dd-MM-yyyy HH:mm"))")
                        Text("Exportprefix: \(meta.ExportPrefix)")
                        Text("SNOMED-versie: \(meta.Snomedversie)")
                    }

                    Image("LCHlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 144)
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Metadata wordt geladen...")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Informatie")
    }

    func formatDate(_ isoDate: String, format: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: isoDate) else { return isoDate }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = format
        displayFormatter.locale = Locale(identifier: "nl_NL")
        return displayFormatter.string(from: date)
    }
}
