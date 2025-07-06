import SwiftUI

struct MenuView: View {
    @EnvironmentObject var model: LCHModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                MenuTile(
                    title: "Complicaties",
                    icon: "list.bullet.rectangle",
                    color: .blue,
                    destination: ComplicatieView().environmentObject(model)
                )

                MenuTile(
                    title: "Codes",
                    icon: "number.square",
                    color: .green,
                    destination: CodeView().environmentObject(model)
                )

                MenuTile(
                    title: "Structuur",
                    icon: "circle.grid.cross.fill",
                    color: .orange,
                    destination: StructuurView().environmentObject(model)
                )

                // <-- This “Matrix” tile now pushes into the same NavigationStack:
                MenuTile(
                    title: "Matrix",
                    icon: "square.grid.3x3.fill",
                    color: .pink,
                    destination: MatrixDummyScreen().environmentObject(model)
                )

                MenuTile(
                    title: "Feedback",
                    icon: "paperplane.circle",
                    color: .purple,
                    destination: FeedbackView(
                        categorie: "Algemeen",
                        actie: "",
                        voorafIngevuld: "",
                        herkomst: "Menu"
                    ).environmentObject(model)
                )

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoView()) {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HelpView()) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .navigationTitle("Hoofdmenu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

