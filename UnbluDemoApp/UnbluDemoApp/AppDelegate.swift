import Foundation
import UIKit
import WebKit
import UnbluCoreSDK
import BackgroundTasks
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate, NetServiceBrowserDelegate {
    static var unbluClient = UnbluClient()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureRemoteNotifications()
        AppDelegate.unbluClient.createConfiguration()
        return true
    }

    private func configureRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            guard error == nil, granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let apnsToken = deviceToken.map { String(format: "%02x", $0 as CVarArg) }.joined()
        UnbluNotificationApi.instance.deviceToken = apnsToken
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        handleRemoteNotification(userInfo)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        handleRemoteNotification(userInfo)
    }

    private func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        do {
            try UnbluNotificationApi.instance.handleRemoteNotification(
                userInfo: userInfo,
                withCompletionHandler: { _ in }
            )
        } catch {
            print("Error handling remote notification: \(error)")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

// MARK: - AppDelegate Extensions
extension AppDelegate {
    static func createVisitorClient(_ cookies: [HTTPCookie]) -> Bool {
        unbluClient.createVisitorClient(cookies)
    }

    static func stop(completionHandler: @escaping () -> Void) {
        unbluClient.stop(completionHandler: completionHandler)
    }

    static func connectToUnbluServer(completionHandler: @escaping () -> Void) {
        unbluClient.startConnection(completionHandler: completionHandler)
    }

    static func getUnbluUiState() -> UnbluUiState {
        unbluClient.unbluUiState
    }

}
