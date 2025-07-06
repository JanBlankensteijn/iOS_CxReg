import SwiftUI

struct DetailView: View {
    let item: Complicatie
    let searchText: String
    let backLabel: String
    @EnvironmentObject var model: LCHModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Combine Code and SHcode prominently at the top
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Code")
                            .font(.headline)
                        HighlightedText(text: item.Code, highlights: searchText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SHcode")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        HighlightedText(text: item.SHcode ?? "-", highlights: searchText)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                }
                Divider()

                Text("Hoofdgroep:")
                    .font(.headline)
                Text("(\(item.Code.prefix(3))) = \(item.GRPtekst ?? "-")")
                    .font(.subheadline)

                Text("Soort:")
                    .font(.headline)
                Text("(\(item.Code.dropFirst(3).prefix(3))) = \(item.SRTtekst ?? "-")")
                    .font(.subheadline)

                Text("Specificatie:")
                    .font(.headline)
                Text("(\(item.Code.dropFirst(6).prefix(3))) = \(item.SPCtekst ?? "-")")
                    .font(.subheadline)

                Text("Locatie:")
                    .font(.headline)
                Text("(\(item.Code.dropFirst(9).prefix(3))) = \(item.LOCtekst ?? "-")")
                    .font(.subheadline)

                Text("Omschrijving:")
                    .font(.headline)
                HighlightedText(text: item.CxTekst, highlights: searchText)

                Text("Synoniemen:")
                    .font(.headline)
                HighlightedText(text: item.Inclusietermen, highlights: searchText, defaultColor: .gray)

                Text("Exclusietermen:")
                    .font(.headline)
                Text(item.Exclusietermen)

                Text("Definitie:")
                    .font(.headline)
                Text(item.Definitie ?? "-")

                Text("Actief:")
                    .font(.headline)
                if item.Actief {
                    Text("ja")
                } else {
                    Text("nee")
                        .foregroundColor(.red)
                }

                Text("SNOMED:")
                    .font(.headline)
                Text(item.Snomed ?? "-")
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text(backLabel)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: FeedbackView(
                        categorie: "Inhoud",
                        actie: "Verander omschrijving",
                        voorafIngevuld: item.Code,
                        herkomst: "Details"
                    )
                ) {
                    Image(systemName: "paperplane.circle")
                }
            }
        }
    }
}

