import SwiftUI

/// A SwiftUI view that displays Complicatie data in a sticky-header matrix with a GRP picker.
struct MatrixDummyScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: LCHModel
    @State private var selectedGRP: String = "ART"
    @State private var selectedItem: Complicatie? = nil
    @State private var showDetail: Bool = false
    @State private var searchText: String = ""

    // All available GRP codes (prefix of Complicatie.Code)
    private var grpCodes: [String] {
        let codes = Set(model.allItems.map { String($0.Code.prefix(3)) })
        return codes.sorted()
    }

    // Filtered Complicatie items by selected GRP
    private var filteredCodes: [Complicatie] {
        model.allItems.filter { String($0.Code.prefix(3)) == selectedGRP }
    }

    // Unique rows (SRTSPC groups)
    private var itemsToShow: [Complicatie] {
        let grouped = Dictionary(grouping: filteredCodes) { String($0.Code.dropFirst(3).prefix(6)) }
        return grouped.values.compactMap { $0.first }.sorted { $0.Code < $1.Code }
    }

    // Unique column locations
    private var locaties: [String] {
        let suffixes = filteredCodes.map { String($0.Code.suffix(3)) }
        return Array(Set(suffixes)).sorted()
    }

    // Full codes set for marking circles
    private var bestaandeCodes: Set<String> {
        Set(filteredCodes.map { $0.Code })
    }

    // Only the active codes
    private var actieveCodes: Set<String> {
        Set(filteredCodes.filter { $0.Actief }.map { $0.Code })
    }

    var body: some View {
//        NavigationStack {
            VStack(spacing: 0) {
                // Picker toolbar
                HStack {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                    Text("GROEP:")
                    Picker("Groep", selection: $selectedGRP) {
                        ForEach(grpCodes, id: \.self) { grp in
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
                
                // Matrix grid
                GeometryReader { geo in
                    MatrixCollectionViewGrid(
                        items: itemsToShow,
                        locaties: locaties,
                        bestaandeCodes: bestaandeCodes,
                        actieveCodes: actieveCodes,
                        onSelect: { grp, srtspc, loc in
                            let code = grp + srtspc + loc
                            if let comp = model.allItems.first(where: { $0.Code == code }) {
                                selectedItem = comp
                                searchText = ""
                                showDetail = true
                            }
                        }
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .navigationTitle("Matrix Compl × Loc")
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
            .navigationDestination(isPresented: $showDetail) {
                if let item = selectedItem {
                    DetailView(item: item, searchText: searchText, backLabel: "Matrix")
                        .environmentObject(model)
                }
            }
 //       }
    }
}

struct MatrixDummyScreen_Previews: PreviewProvider {
    static var previews: some View {
        MatrixDummyScreen()
            .environmentObject(LCHModel())
    }
}

