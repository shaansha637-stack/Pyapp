import SwiftUI

@main
struct OTPTesterApp: App {
    @StateObject private var store = MockOTPStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
