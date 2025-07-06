import SwiftUI

struct StructuurView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: LCHModel
    @State private var searchText = ""
    @State private var filteredItems: [Complicatie] = []
    @State private var variant: String = "A"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("GROEP: ")
                Picker("Groep", selection: Binding(
                    get: { model.filter?.code ?? "ALLE" },
                    set: { newValue in model.filter = (type: "GRP", code: newValue); filterItems() }
                )) {
                    Text("ALLE GROEPEN").tag("ALLE")
                    ForEach(Array(Set(model.allItems.map { String($0.Code.prefix(3)) })).sorted(), id: \.self) { grp in
                        Text(grp).tag(grp)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.black)
                                Spacer()
            }
            .padding()
            .background(Color.yellow)
            .cornerRadius(8)
            .padding(.horizontal)

            Picker("Toon", selection: $variant) {
                Text("Complicaties").tag("A")
                Text("Locaties").tag("B")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: variant) { _ in filterItems() }

            HStack {
                TextField(
                       variant == "A"
                           ? "Zoek complicatie"
                           : "Zoek locatie",
                       text: $searchText
                   )
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText, initial: true) { _, _ in
                        filterItems()
                    }
//                    .onChange(of: searchText) { _ in filterItems() }
                    .disableAutocorrection(true)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        filterItems()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)

            if filteredItems.isEmpty {
                Spacer()
                Text("Geen resultaten.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                List(filteredItems, id: \.Code) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HighlightedText(
                            text: weergeefTekst(item),
                            highlights: searchText,
                            defaultColor: .primary,
                            codeOnly: false
                        )
                        .bold()

                        HighlightedText(
                            text: relevanteCode(item),
                            highlights: searchText,
                            defaultColor: .gray,
                            codeOnly: true
                        )
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .navigationTitle("Structuur")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    model.filter = nil
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Menu")
                    }
                }
            }
        }
        .onAppear {
            filterItems()
        }
    }

    func weergeefTekst(_ item: Complicatie) -> String {
        let parts = item.CxTekst.components(separatedBy: ";")
        if parts.count < 2 { return item.CxTekst }
        return variant == "A" ? parts[0].trimmingCharacters(in: .whitespaces) : parts[1].trimmingCharacters(in: .whitespaces)
    }

    func relevanteCode(_ item: Complicatie) -> String {
        let code = item.Code
        switch variant {
        case "A": return "[" + code.prefix(3) + code.dropFirst(3).prefix(6) + "*]"
        case "B": return "[" + code.prefix(3) + "**" + code.suffix(3) + "]"
        default: return ""
        }
    }

    func filterItems() {
        // 1) Ensure there's always a GRP=ALLE filter
        if model.filter == nil {
            model.filter = (type: "GRP", code: "ALLE")
        }

        // 2) Build the unique-by-variant dictionary
        var unieke: [String: Complicatie] = [:]
        for item in model.allItems where item.Actief {
            let code = item.Code

            // respect the model.filter
            if let f = model.filter, f.code != "ALLE",
               code.prefix(3) != f.code {
                continue
            }

            // pick key based on variant
            let key: String
            switch variant {
            case "A":
                key = String(code.dropFirst(3).prefix(6))
            case "B":
                key = String(code.suffix(3))
            default:
                key = code
            }

            if unieke[key] == nil {
                unieke[key] = item
            }
        }

        // 3) Prepare the search terms (split on whitespace, drop empties)
        let terms = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        // 4) Filter: keep only those items for which *all* terms match
        filteredItems = unieke.values
            .filter { item in
                // if no terms, show everything
                guard !terms.isEmpty else { return true }

                return terms.allSatisfy { term in
                    // Code‐style match: all‐uppercase and length 3 (or 6 for A)
                    if term == term.uppercased(),
                       (term.count == 3 || (variant == "A" && term.count == 6)) {
                        let code = item.Code
                        switch variant {
                        case "A":
                            if term.count == 3 {
                                let srt = code.dropFirst(3).prefix(3)
                                let spc = code.dropFirst(6).prefix(3)
                                return srt == term || spc == term || code.prefix(3) == term
                            } else {
                                let srtspc = code.dropFirst(3).prefix(6)
                                return srtspc == term || (code.prefix(3) + srtspc) == term
                            }
                        case "B":
                            let loc = code.suffix(3)
                            return loc == term || code.prefix(3) == term
                        default:
                            return false
                        }
                    }
                    // Otherwise, do a case-insensitive text‐contains match
                    let parts = item.CxTekst.components(separatedBy: ";")
                    guard parts.count >= 2 else { return false }
                    let tekst = variant == "A" ? parts[0] : parts[1]
                    return tekst.lowercased().contains(term.lowercased())
                }
            }
            // 5) Sort by your relevanteCode(_:) helper
            .sorted { relevanteCode($0) < relevanteCode($1) }
    }

}

