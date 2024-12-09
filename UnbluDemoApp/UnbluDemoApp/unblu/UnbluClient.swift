import Foundation
import UnbluCoreSDK
import UnbluMobileCoBrowsingModule
import SwiftUI

class ConversationInterceptor: UnbluConversationInterceptor {
    func conversationIsPreparing(
        withType conversationType: ConversationType,
        customVisitorData: String?,
        onComplete: @escaping (String?) -> Void
    ) {
        print("Conversation intercepted data: \(customVisitorData ?? "nil")")
        onComplete(customVisitorData)
    }
}

public class UnbluUiState: ObservableObject {
    @Published var isOverview: Bool = true
    @Published var unbluView: UIView?
}

public class UnbluClient {
    var callModule: UnbluCallModuleApi?
    var unbluVisitorClient: UnbluVisitorClient?
    var userNotificationCenter = NotificationCenterDelegate()
    var unbluConfiguration: UnbluClientConfiguration?
    var visitorDelegate: VisitorClientDelegate?
    var unbluUiState = UnbluUiState()
    var callDelegate: CallModuleDelegate?
    var coDelegate: CoBrowsingDelegate?
    var coBrowsingModule: UnbluMobileCoBrowsingModuleApi?

    func createConfiguration() {
        UnbluClientConfiguration.callKitProviderIconResourceName = Configuration.callKitIcon
        unbluConfiguration = createUnbluConfig()
        unbluConfiguration?.unbluPushNotificationVersion = .Encrypted //.EncryptedService

         // Configure URL Whitelist
        unbluConfiguration?.internalUrlPatternWhitelist = [
            try! NSRegularExpression(pattern: "^.*$", options: [])
        ]

        // Register Call Module
        callModule = UnbluCallModuleProvider.create()
        try? unbluConfiguration?.register(module: callModule!)
        callDelegate = CallModuleDelegate(self)
        callModule?.delegate = callDelegate

        // Configure CoBrowsing Module
        let coBrowsingConfig = UnbluMobileCoBrowsingModuleConfiguration(
            privateViews: [],
            maxWindowCapturingLevel: .alert + 2
        )
        coBrowsingModule = UnbluMobileCoBrowsingModuleProvider.create(config: coBrowsingConfig)
        try? unbluConfiguration?.register(module: coBrowsingModule!)
        coDelegate = CoBrowsingDelegate(self)
        coBrowsingModule?.delegate = coDelegate

        // Set Notification Center Delegate
        UNUserNotificationCenter.current().delegate = userNotificationCenter
    }

    func createVisitorClient(_ cookies: [HTTPCookie]) -> Bool {
        unbluConfiguration?.customCookies = Set(
            cookies.map { UnbluCookie(name: $0.name, value: $0.value, expiryDate: $0.expiresDate) }
        )
        return createVisitorClient()
    }

    func createVisitorClient() -> Bool {
        guard let config = unbluConfiguration else { return false }
        
        unbluVisitorClient = Unblu.createVisitorClient(withConfiguration: config)
        unbluVisitorClient?.logLevel = .verbose
        unbluVisitorClient?.enableDebugOutput = true

        visitorDelegate = VisitorClientDelegate(self)
        callDelegate?.unbluClient = self
        unbluVisitorClient?.visitorDelegate = visitorDelegate

        DispatchQueue.main.async {
            self.unbluUiState.unbluView = self.unbluVisitorClient?.view
        }

        unbluVisitorClient?.conversationInterceptor = ConversationInterceptor()
        return true
    }

    private func createUnbluConfig() -> UnbluClientConfiguration {
        var configuration = UnbluClientConfiguration(
            unbluBaseUrl: Configuration.unbluServerUrl,
            apiKey: Configuration.unbluApiKey,
            preferencesStorage: UserDefaultsPreferencesStorage(),
            fileDownloadHandler: UnbluDefaultFileDownloadHandler(),
            externalLinkHandler: UnbluDefaultExternalLinkHandler()
        )
        configuration.entryPath = Configuration.unbluServerEntryPath
        return configuration
    }

    func startConnection(completionHandler: @escaping () -> Void) {
        guard let client = unbluVisitorClient else {
            completionHandler()
            return
        }

        client.isInitialized { isInitialized in
            if !isInitialized {
                client.start { result in
                    completionHandler()
                }
            }
        }
    }

    func stop(completionHandler: @escaping () -> Void) {
        guard let client = unbluVisitorClient else {
            completionHandler()
            return
        }

        client.stop { _ in
            self.callModule = nil
            self.unbluVisitorClient = nil
            self.unbluConfiguration = nil
            self.visitorDelegate = nil
            self.coDelegate = nil
            self.coBrowsingModule = nil
            completionHandler()
        }
    }
}
