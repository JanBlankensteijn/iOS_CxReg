//
//  MatrixScreen 2.swift
//  LCHappiOS
//
//  Created by Jan Blankensteijn on 17/06/2025.
//


import SwiftUI

struct MatrixScreen: View {
    @EnvironmentObject var model: LCHModel
    @State private var selectedGRP: String = ""
    @State private var hasAppeared = false
    @State private var searchText = ""

    var gefilterdeCodes: [Complicatie] {
        guard !selectedGRP.isEmpty else { return [] }
        return model.allItems.filter { $0.Actief && $0.Code.prefix(3) == selectedGRP }
    }

    var gefilterdeItems: [Complicatie] {
        let uniek = Dictionary(grouping: gefilterdeCodes) { String($0.Code.prefix(9)) }
        return uniek.values.compactMap { $0.first }.sorted { $0.Code < $1.Code }
    }

    var gefilterdeLocaties: [String] {
        let codes = gefilterdeCodes.map { String($0.Code.suffix(3)) }
        return Array(Set(codes)).sorted()
    }

    var bestaandeCodes: Set<String> {
        Set(gefilterdeCodes.map { $0.Code })
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.3x3.fill")
                Picker("GROEP", selection: $selectedGRP) {
                    ForEach(model.grpItems.map { $0.Code }.sorted(), id: \.self) { grp in
                        Text(grp).tag(grp)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Spacer()
            }
            .padding()
            .background(Color.white)

            HStack {
                TextField("Zoek complicatie", text: $searchText)
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
            }
            .padding(.horizontal)

            // HORIZONTALE EN VERTICALE SCROLL ZONDER SPLITSEN
            ScrollView([.vertical, .horizontal]) {
                MatrixCollectionViewGrid(
                    items: gefilterdeItems,
                    locaties: gefilterdeLocaties,
                    bestaandeCodes: bestaandeCodes
                )
                .frame(
                    width: CGFloat(gefilterdeLocaties.count) * MatrixLayout.kolombreedte + MatrixLayout.rijheaderbreedte,
                    height: CGFloat(gefilterdeItems.count + 1) * MatrixLayout.rijhoogte + MatrixLayout.headerhoogte
                )
            }
        }
        .navigationTitle("Matrix")
        .onAppear {
            if !hasAppeared {
                selectedGRP = model.grpItems.first?.Code ?? ""
                hasAppeared = true
            }
        }
    }
}
