import SwiftUI
import SwiftData

@main
struct LCHappiOSApp: App {
    @StateObject var model = LCHModel()

     var body: some Scene {
         WindowGroup {
             StartupView()
                 .environmentObject(model)
         }
     }
 }
