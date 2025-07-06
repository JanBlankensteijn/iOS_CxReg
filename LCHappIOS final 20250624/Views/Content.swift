import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: LCHModel
    @State private var showIntro = false
    @State private var searchText = ""
    @State private var filteredItems: [Complicatie] = []
    @State private var showOnlyActive = true
    @State private var excludedCodes: Set<String> = []
    
    // 👇 toegevoegd voor correcte back button in InfoView
    
    var body: some View {
        NavigationView {
            if showIntro {
                VStack(spacing: 20) {
                    Image("LCHlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .padding(.top, 60)
                    
                    Text("Lijst Complicaties Heelkunde")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Text("© Jan D. Blankensteijn")
                        .foregroundColor(.blue)
                    
                    Text("versie \(model.metadata?.Exportdatum ?? "-")")
                        .foregroundColor(.red)
                    
                    if !model.allItems.isEmpty {
                        Text("✅ \(model.allItems.count) ingelezen records")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showIntro = false
                    }
                }
            } else {
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
                            
                            Button(action: {
                                searchText = ""
                                filteredItems = []
                                excludedCodes = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if !searchText.isEmpty {
                            let total = model.allItems.filter { !showOnlyActive || $0.Actief }.count
                            let prefix = showOnlyActive ? "actieve complicaties" : "(alle) complicaties"
                            let color = showOnlyActive ? Color.primary : Color.red
                            Text("\(filteredItems.count) van \(total) \(prefix)")
                                .font(.caption)
                                .foregroundColor(color)
                                .padding(.horizontal)
                        }
                        
                        if !excludedCodes.isEmpty {
                            HStack {
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
                            }
                            .padding(.horizontal)
                        }
                        
                        if !filteredItems.isEmpty && !searchText.isEmpty {
                            List(filteredItems.sorted(by: { $0.Code < $1.Code }), id: \.Code) { item in
                                NavigationLink(destination: DetailView(item: item, searchText: searchText)) {
                                    VStack(alignment: .leading) {
                                        if item.Actief {
                                            HighlightedText(text: item.CxTekst, highlights: searchText, defaultColor: .primary).bold()
                                        } else {
                                            HighlightedText(text: item.CxTekst, highlights: searchText, defaultColor: .red)
                                                .strikethrough(true, color: .red)
                                                .bold()
                                        }
                                        if !item.Inclusietermen.isEmpty {
                                            HighlightedText(text: "Synoniemen: \(item.Inclusietermen)", highlights: searchText, defaultColor: .gray)
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
                            VStack(spacing: 2) {
                                Text("Geen ") + Text("actieve ").bold() + Text("complicaties gevonden.")
                                Text("Pas zoektermen aan.")
                                Text("Als ook geen ") + Text("inactieve ").bold() + Text("complicaties, \n overweeg dan feedback.")
                                
                                NavigationLink(
                                    destination: FeedbackView(
                                        categorie: "Inhoud",
                                        actie: "voeg toe"
                                    )
                                ) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "paperplane.circle")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        Text("Geef feedback")
                                            .font(.body)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        
                        // 👇 Onzichtbare NavigationLink voor InfoView
                    }
                }
                .navigationTitle("Complicaties")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: HelpView()) {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: InfoView()) {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                .onAppear {
                    if model.allItems.isEmpty {
                        showIntro = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showIntro = false
                        }
                    }
                }
            }
        }
    }
    
    func filterItems() {
        // in deze filterfunctie wordt dus ook gekeken naar de exlcusietermen
        // die worden als geheel al uit de CxTekst_zoek gehaald in export
        // maar dat voorkomt niet het matchen om segmenten van woorden op de zoekterm
        // daarvoor moet de zoekstring toch echt (negatief) gematcht op de exlcusietermen zelf
        // dat kan niet elk EPD, maar wel de LCHapp en CxRegVBA
        
        let words = searchText.lowercased()
            .split(separator: " ")
            .filter { !$0.hasPrefix("complicatie") && !$0.hasPrefix("hlk") }
        
        filteredItems = model.allItems.filter { item in
            let tekst = item.CxTekst_zoek.lowercased()
            let exclusie = item.Exclusietermen.lowercased()
            
            let voldoetAanZoekwoorden = words.allSatisfy { word in
                tekst.contains(word) && (exclusie.isEmpty || !exclusie.contains(word))
            }
            
            return (!showOnlyActive || item.Actief) &&
            voldoetAanZoekwoorden &&
            !excludedCodes.contains(item.Code)
        }
    }
}
