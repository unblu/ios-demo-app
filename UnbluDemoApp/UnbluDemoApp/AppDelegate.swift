import Foundation
import UIKit
import WebKit
import UnbluCoreSDK
import BackgroundTasks
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate, NetServiceBrowserDelegate {
    static var callDelegate = IncomingCallDelegate()
    static var unbluClient = UnbluClient()
    static let unbluSecureStorage = UnbluKeychainPreferencesStorage(
        accessControl: .afterFirstUnlock(thisDeviceOnly: false),
        shared: true
    )
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appLog.notice("UnbluDemo [AppDelegate] didFinishLaunching")
        configureRemoteNotifications()
        observeLifecycleNotifications()
        AppDelegate.unbluClient.createConfiguration()
        AppDelegate.unbluClient.startPendingCallPolling()
        UnbluNotificationApi.instance.keychainPreferencesStorage = AppDelegate.unbluSecureStorage
        UnbluNotificationApi.instance.incomingCallDelegate = AppDelegate.callDelegate

        return true
    }

    private func observeLifecycleNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            appLog.notice("UnbluDemo [AppDelegate] didBecomeActive")
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            appLog.notice("UnbluDemo [AppDelegate] didEnterBackground")
        }
    }

    private func configureRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
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
            appLog.notice("UnbluDemo Error handling remote notification: \(String(describing: error), privacy: .public)")
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
