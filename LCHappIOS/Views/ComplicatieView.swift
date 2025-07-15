import SwiftUI


struct ComplicatieView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: LCHModel
    @State private var searchText = ""
    @State private var filteredItems: [Complicatie] = []
    @State private var showOnlyActive = true
    @State private var excludedCodes: Set<String> = []

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.blue.opacity(0.05).edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 12) {
                Toggle("Toon alleen actieve complicaties", isOn: $showOnlyActive)
                    .padding(.horizontal)
                    .onChange(of: showOnlyActive, initial: true) { _, _ in
                        filterItems()
                    }

                HStack {
                    TextField("Zoek complicatie", text: $searchText)
                        .padding(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText, initial: true) { _, _ in
                            filterItems()
                        }
                        .disableAutocorrection(true)

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            filteredItems = []
                            excludedCodes = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)

                let total = model.allItems.filter { !showOnlyActive || $0.Actief }.count
                let prefix = showOnlyActive ? "actieve complicaties" : "(alle) complicaties"
                let color = showOnlyActive ? Color.primary : Color.red

                Text("\(filteredItems.count) van \(total) \(prefix)")
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)

                if !excludedCodes.isEmpty {
                    HStack {
                        Spacer()
                        Text("Uitsluitingen actief (n=\(excludedCodes.count))")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Button(action: {
                            excludedCodes = []
                            filterItems()
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                if !filteredItems.isEmpty {
                    List(filteredItems.sorted(by: { $0.CxTekst < $1.CxTekst }), id: \.Code) { item in
                        NavigationLink(destination: DetailView(item: item, searchText: searchText,backLabel: "Complicaties")) {
                            VStack(alignment: .leading) {
                                if item.Actief {
                                    HighlightedText(text: item.CxTekst, highlights: searchText, defaultColor: .primary, codeOnly: false).bold()
                                } else {
                                    HighlightedText(text: item.CxTekst, highlights: searchText, defaultColor: .red, codeOnly: false)
                                        .strikethrough(true, color: .red)
                                        .bold()
                                }
                                if !item.Inclusietermen.isEmpty {
                                    let synoniemenMetCode = "Synoniemen: \(item.Inclusietermen) [\(item.Code)]"
                                    HighlightedText(text: synoniemenMetCode, highlights: searchText, defaultColor: .gray, codeOnly: true)
                                        .font(.caption)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                excludedCodes.insert(item.Code)
                                filterItems()
                            } label: {
                                Label("Uitsluiten", systemImage: "minus.circle")
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                } else if searchText != "" {
                    List {
                        Section {
                            VStack(alignment: .center, spacing: 8) {
                                Text("Geen resultaten.")
                                    .bold()
                                Text("Pas zoektermen aan.")
                                NavigationLink(
                                    destination: FeedbackView(
                                        categorie: "Inhoud",
                                        actie: "voeg toe",
                                        voorafIngevuld: "Zoekterm: \(searchText)"
                                    )
                                ) {
                                    HStack(spacing: 6) {
                                        Spacer()
                                        Text("Geef feedback")
                                            .font(.body)
                                            .foregroundColor(.blue)
                                        Image(systemName: "paperplane.circle")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        Spacer()
                                    }
                                }
                            }
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollDismissesKeyboard(.immediately)
                }
            }
        }
        .navigationTitle("Complicaties")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
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

    func filterItems() {
        let words = searchText.split(separator: " ").map(String.init)
        filteredItems = model.allItems.filter { item in
            let tekst = item.CxTekst_zoek.lowercased()
            let exclusie = item.Exclusietermen.lowercased()
            let code = item.Code.uppercased()

            let voldoetAanZoekwoorden = words.allSatisfy { word in
                if word.count == 3 && word.uppercased() == word {
                    return (
                        code.prefix(3) == word ||
                        code.dropFirst(3).prefix(3) == word ||
                        code.dropFirst(6).prefix(3) == word ||
                        code.dropFirst(9).prefix(3) == word
                    )
                } else {
                    let w = word.lowercased()
                    return tekst.contains(w) && (exclusie.isEmpty || !exclusie.contains(w))
                }
            }

            return (!showOnlyActive || item.Actief) &&
            voldoetAanZoekwoorden &&
            !excludedCodes.contains(item.Code)
        }
    }
}

