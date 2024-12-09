import SwiftUI


@main
struct UnbluDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var unbluState = AppDelegate.getUnbluUiState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(unbluState)
        }
    }
    

}
