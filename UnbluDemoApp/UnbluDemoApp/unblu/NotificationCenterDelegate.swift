import Foundation
import UnbluCoreSDK

 class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        do {
            try UnbluNotificationApi.instance.didReceive(notificationResponse: response, withCompletionHandler: completionHandler)
        } catch {
            print("not unblu notification")
            completionHandler()
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        do {
            try UnbluNotificationApi.instance.willPresent(notification: notification, withCompletionHandler: completionHandler)
        } catch {
            print("not unblu notification")
            completionHandler([.alert, .badge, .sound])
        }
    }
}
