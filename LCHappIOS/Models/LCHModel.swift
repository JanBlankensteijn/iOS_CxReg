import Foundation

@MainActor
class LCHModel: ObservableObject {
    @Published var allItems: [Complicatie] = []
    @Published var metadata: LCHInfo?
    @Published var grpItems: [CodeTekst] = []
    @Published var srtItems: [CodeTekst] = []
    @Published var spcItems: [CodeTekst] = []
    @Published var locItems: [CodeTekst] = []
    @Published var loadProgress: Double = 0.0
    @Published var filter: (type: String, code: String)? = nil

    func loadRemoteEncryptedJSON() {
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let url = URL(string: "https://raw.githubusercontent.com/JanBlankensteijn/CxReg/main/LCH/LCH_encrypted.json?\(timestamp)") else {
            print("❌ Ongeldige URL")
            return
        }

        Task {
            do {
                var request = URLRequest(url: url)
                request.cachePolicy = .reloadIgnoringLocalCacheData

                let (data, _) = try await URLSession.shared.data(for: request)
                let decryptedData = decryptXOR(data: data, withPassword: "Cx3e9")

                let wrapper = try JSONDecoder().decode(LCHWrapper.self, from: decryptedData)
                self.metadata = wrapper.metadata

                let prefix = wrapper.metadata.ExportPrefix
                let origineleItems = wrapper.data

                var geladen: [Complicatie] = []
                for (i, item) in origineleItems.enumerated() {
                    var modified = item
                    if modified.CxTekst.hasPrefix(prefix) {
                        modified.CxTekst = String(modified.CxTekst.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                    }
                    geladen.append(modified)
                    self.loadProgress = Double(i + 1) / Double(origineleItems.count)

                    try? await Task.sleep(nanoseconds: 1_000_000) // 1 ms vertraging per item
                }

                self.allItems = geladen
                self.grpItems = wrapper.GRP ?? []
                self.srtItems = wrapper.SRT ?? []
                self.spcItems = wrapper.SPC ?? []
                self.locItems = wrapper.LOC ?? []

  //              print("✅ \(allItems.count) records geladen via encrypted JSON")
            } catch {
                print("❌ Fout bij decrypten/parsen: \(error)")
            }
        }
    }
}

func decryptXOR(data: Data, withPassword password: String) -> Data {
    let pwBytes = Array(password.utf8)
    return Data(zip(data, pwBytes.cycled()).map { $0 ^ $1 })
}

extension Array {
    func cycled() -> AnyIterator<Element> {
        var i = 0
        return AnyIterator {
            defer { i = (i + 1) % self.count }
            return self[i]
        }
    }
}

