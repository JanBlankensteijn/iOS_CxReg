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
                TextField("Zoek", text: $searchText)
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { _ in filterItems() }
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
                        Text("Codes")
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
        if model.filter == nil {
            model.filter = (type: "GRP", code: "ALLE")
        }
        if model.filter == nil {
            model.filter = (type: "GRP", code: "ALLE")
        }

        var unieke: [String: Complicatie] = [:]

        for item in model.allItems {
            guard item.Actief else { continue }
            let code = item.Code

            if let f = model.filter, f.code != "ALLE" {
                guard code.prefix(3) == f.code else { continue }
            }

            let key: String
            switch variant {
            case "A": key = String(code.dropFirst(3).prefix(6))
            case "B": key = String(code.suffix(3))
            default: key = code
            }

            if unieke[key] == nil {
                unieke[key] = item
            }
        }

        let zoek = searchText.trimmingCharacters(in: .whitespaces)

        filteredItems = unieke.values.filter { item in
            let parts = item.CxTekst.components(separatedBy: ";")
            guard parts.count >= 2 else { return false }
            let tekst = variant == "A" ? parts[0] : parts[1]
            let tekstLower = tekst.lowercased()

            if zoek.isEmpty { return true }

            if zoek == zoek.uppercased() && (zoek.count == 3 || (variant == "A" && zoek.count == 6)) {
                let code = item.Code
                switch variant {
                case "A":
                    if zoek.count == 3 {
                        let srt = code.dropFirst(3).prefix(3)
                        let spc = code.dropFirst(6).prefix(3)
                        return srt == zoek || spc == zoek || code.prefix(3) == zoek
                    } else {
                        let srtspc = code.dropFirst(3).prefix(6)
                        return srtspc == zoek || code.prefix(3) + srtspc == zoek
                    }
                case "B":
                    let loc = code.suffix(3)
                    return loc == zoek || code.prefix(3) == zoek
                default:
                    return false
                }
            } else {
                return tekstLower.contains(zoek.lowercased())
            }
        }.sorted { relevanteCode($0) < relevanteCode($1) }
    }
}

