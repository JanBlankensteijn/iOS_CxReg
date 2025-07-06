import SwiftUI

struct StartupView: View {
    @EnvironmentObject var model: LCHModel
    @State private var showMenu = false

    var body: some View {
        Group {
            if showMenu {
                MenuView()
            } else {
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

                    ProgressView(value: model.loadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                    Text("🔄 Laden…  \(Int(model.loadProgress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.white)
            }
        }
        // Zodra deze view verschijnt, start het laden automatisch
        .task {
            // Dit staat in LCHModel, en vult allItems, grpItems, etc. :contentReference[oaicite:0]{index=0}
            model.loadRemoteEncryptedJSON()
            
            // Wacht tot laden klaar is (loadProgress == 1.0)
            // We checken elke 0.1s; zodra geladen, tonen we het menu
            while model.loadProgress < 1.0 {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            showMenu = true
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
            .environmentObject(LCHModel())
    }
}

