//
//  MatrixScreen 3.swift
//  LCHappiOS
//
//  Created by Jan Blankensteijn on 19/06/2025.
//


// MatrixScreen.swift – definitieve matrix met aparte horizontale en verticale scroll

import SwiftUI

struct MatrixScreen: View {
    @EnvironmentObject var model: LCHModel
    @State private var selectedGRP: String = ""
    @State private var hasAppeared = false

    var allGRPcodes: [String] {
        model.grpItems.map { $0.Code }.sorted()
    }

    var gefilterdeCodes: [Complicatie] {
        guard !selectedGRP.isEmpty else { return [] }
        return model.allItems.filter { $0.Actief && $0.Code.uppercased().prefix(3) == selectedGRP }
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

    var totaleBreedte: CGFloat {
        CGFloat(gefilterdeLocaties.count) * MatrixLayout.kolombreedte + MatrixLayout.rijheaderbreedte
    }

    var totaleHoogte: CGFloat {
        CGFloat(gefilterdeItems.count + 1) * MatrixLayout.rijhoogte + MatrixLayout.headerhoogte
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.3x3.fill")
                Picker("GROEP", selection: $selectedGRP) {
                    ForEach(allGRPcodes, id: \.self) { grp in
                        Text(grp).tag(grp)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Spacer()
            }
            .padding()
            .background(Color.white)
            .onAppear {
                if !hasAppeared {
                    selectedGRP = model.grpItems.first?.Code ?? ""
                    hasAppeared = true
                }
            }

            if gefilterdeItems.isEmpty || gefilterdeLocaties.isEmpty {
                Text("⚠️ Geen matrixgegevens voor \(selectedGRP)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                GeometryReader { geo in
                    ScrollView(.horizontal) {
                        VStack {
                            ScrollView(.vertical) {
                                MatrixCollectionViewGrid(
                                    items: gefilterdeItems,
                                    locaties: gefilterdeLocaties,
                                    bestaandeCodes: bestaandeCodes
                                )
                                .frame(width: totaleBreedte, height: totaleHoogte)
                            }
                        }
                        .frame(width: max(totaleBreedte, geo.size.width))
                    }
                }
            }
        }
        .navigationTitle("Matrix")
    }
}

