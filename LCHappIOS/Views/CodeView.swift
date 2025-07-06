import SwiftUI

struct CodeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: LCHModel
    @State private var selectedType: String = "GRP"
    @State private var searchText: String = ""
    @State private var filteredItems: [CodeTekst] = []
    @State private var selectedItem: CodeTekst? = nil
    @State private var navigateToFeedback = false
    @State private var navigateToStructuur = false

    var currentItems: [CodeTekst] {
        switch selectedType {
        case "GRP": return model.grpItems
        case "SRT": return model.srtItems
        case "SPC": return model.spcItems
        case "LOC": return model.locItems
        default: return []
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Picker("Categorie", selection: $selectedType) {
                Text("GRP").tag("GRP")
                Text("SRT").tag("SRT")
                Text("SPC").tag("SPC")
                Text("LOC").tag("LOC")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.top, .horizontal])
            .onChange(of: selectedType) { _ in filterItems() }

            HStack {
                TextField("Zoek code of tekst", text: $searchText)
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

            let total = currentItems.count
            Text("\(filteredItems.count) van \(total) codes")
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.horizontal)

            List {
                if !filteredItems.isEmpty {
                    ForEach(filteredItems) { item in
                        HStack(alignment: .top, spacing: 4) {
                            Text(item.Code)
                                .font(.callout)
                                .bold()
                                .lineLimit(2)
                                .frame(width: 50, alignment: .leading)
                                .padding(.horizontal, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(3)

                            HighlightedText(text: item.Tekst, highlights: searchText, defaultColor: .primary)
                                .font(.callout)
                                .lineLimit(2)
                        }
                        .listRowInsets(EdgeInsets())
                        .swipeActions {
                            Button {
                                selectedItem = item
                                navigateToFeedback = true
                            } label: {
                                Label("Feedback", systemImage: "paperplane.circle")
                            }
                            .tint(.blue)

                            if selectedType == "GRP" {
                                Button {
                                    model.filter = (type: selectedType, code: item.Code)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        navigateToStructuur = true
                                    }
                                } label: {
                                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Geen resultaten.")
                            .bold()
                        Text("Pas zoektermen aan.")
                        NavigationLink(
                            destination: FeedbackView(
                                categorie: "Inhoud",
                                actie: "voeg toe",
                                voorafIngevuld: "Categorie: \(selectedType), Zoekterm: \(searchText)"
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
            .environment(\.defaultMinListRowHeight, 10)

            NavigationLink(
                destination:
                    Group {
                        if let item = selectedItem {
                            FeedbackView(
                                categorie: "Inhoud",
                                actie: "Verander omschrijving",
                                voorafIngevuld: "Betreft: \(titelVoorType()): \(item.Code), \(item.Tekst)"
                            )
                        }
                    },
                isActive: $navigateToFeedback
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(destination: StructuurView().environmentObject(model), isActive: $navigateToStructuur) {
                EmptyView()
            }
            .hidden()
        }
        .navigationTitle("Codes")
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
        let terms = searchText.lowercased().split(separator: " ").map(String.init)
        filteredItems = currentItems.filter { item in
            let zoekveld = "\(item.Code) \(item.Tekst)".lowercased()
            return terms.allSatisfy { zoekveld.contains($0) }
        }
    }

    func titelVoorType() -> String {
        switch selectedType {
        case "GRP": return "Hoofdgroep"
        case "SRT": return "Soort"
        case "SPC": return "Specificatie"
        case "LOC": return "Locatie"
        default: return "Categorie"
        }
    }
}

