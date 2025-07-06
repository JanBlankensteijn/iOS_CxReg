
import SwiftUI
import Foundation

struct Feedback: Codable {
    let datum: String
    let verzender: String
    let categorie: String
    let subcategorie: String?
    let feedback: String
}

enum FeedbackCategorie: String, CaseIterable, Identifiable {
    case UX = "UX"
    case Inhoud = "Inhoud"
    case Fout = "Fout"
    case Overig = "Overig"
    var id: String { self.rawValue }
}

enum UXScherm: String, CaseIterable, Identifiable {
    case hoofdmenu = "Hoofdmenu"
    case complicaties = "Complicaties"
    case codelijst = "Codes"
    case structuur = "Structuur"
    case matrix = "Matrix"
    case feedback = "Feedback"
    case details = "Details"
    case info = "Info"
    case help = "Help"
    var id: String { self.rawValue }
}

enum InhoudActie: String, CaseIterable, Identifiable {
    case voegToe = "Voeg compLOCatie toe"
    case verwijder = "Inactiveer compLOCatie"
    case bewerkOmschrijving = "Verander omschrijving"
    case aanpassingSynoniemen = "Verander synoniemen/excl.-termen"
    case bewerkDefinitie = "Bewerk definitie"
    case snomed = "Herzie Snomed"
    var id: String { self.rawValue }
}

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss

    let voorafIngevuld: String?
    let herkomst: String?

    @State private var verzender = ""
    @State private var categorie: FeedbackCategorie
    @State private var geselecteerdeUXScherm: UXScherm = .hoofdmenu
    @State private var geselecteerdeInhoudActie: InhoudActie
    @State private var feedback: String = ""
    @State private var verzonden = false

    init(categorie: String = "UX", actie: String = "CompLOCaties", voorafIngevuld: String? = nil, herkomst: String? = nil) {
        _categorie = State(initialValue: FeedbackCategorie(rawValue: categorie) ?? .UX)
        _geselecteerdeInhoudActie = State(initialValue: InhoudActie(rawValue: actie) ?? .voegToe)
        self.voorafIngevuld = voorafIngevuld
        self.herkomst = herkomst
    }

    var body: some View {
        Form {
            Section(header: Text("Categorie")) {
                Picker("Categorie", selection: $categorie) {
                    ForEach(FeedbackCategorie.allCases) { categorie in
                        Text(categorie.rawValue).tag(categorie)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if categorie == .UX {
                Section(header: Text("Scherm")) {
                    Picker("Scherm", selection: $geselecteerdeUXScherm) {
                        ForEach(UXScherm.allCases) { scherm in
                            Text(scherm.rawValue).tag(scherm)
                        }
                    }
                }
            } else if categorie == .Inhoud {
                Section(header: Text("Actie")) {
                    Picker("Actie", selection: $geselecteerdeInhoudActie) {
                        ForEach(InhoudActie.allCases) { actie in
                            Text(actie.rawValue).tag(actie)
                        }
                    }
                }
            }

            Section(header: Text("Feedback")) {
                TextEditor(text: $feedback)
                    .frame(minHeight: 120)
                    .autocorrectionDisabled(true)
            }

            Section(header: Text("Verzender (optioneel)")) {
                TextField("e-mail of leeg laten", text: $verzender)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            Section(header: Text("Voeg z.m. foto/bestand toe")) {
                Text("(bestandsupload volgt in een latere versie)")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

            Button("Verzend feedback") {
                verzendFeedback()
            }
            .disabled(feedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if verzonden {
                Text("✅ Feedback verzonden").foregroundColor(.green)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(herkomst ?? "")
                    }
                }
            }
        }
        
        
        
        .onAppear {
            if let vooraf = voorafIngevuld, !vooraf.isEmpty, feedback.isEmpty {
                feedback = vooraf
            }
        }
    }

    func verzendFeedback() {
        let now = ISO8601DateFormatter().string(from: Date())
        let subcat = (categorie == .UX) ? geselecteerdeUXScherm.rawValue :
                     (categorie == .Inhoud ? geselecteerdeInhoudActie.rawValue : nil)

        let f = Feedback(datum: now, verzender: verzender, categorie: categorie.rawValue, subcategorie: subcat, feedback: feedback)

        guard let jsonData = try? JSONEncoder().encode(f),
              let url = URL(string: "https://webhook.site/2f4562ec-11b3-4ef8-9280-a1cf8d1cec77") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                verzonden = true
                feedback = ""
                categorie = .UX
                verzender = ""
            }
        }.resume()
    }
}

