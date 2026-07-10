import Foundation
import CallKit
import PushKit
import UIKit
import UnbluCoreSDK

class LoggingCallKitProvider: NSObject, UnbluCallKitApi, CXProviderDelegate, PKPushRegistryDelegate {

    fileprivate static let tag = String(describing: LoggingCallKitProvider.self)

    private static var provider: CXProvider?

    private var registry = PKPushRegistry(queue: .main)

    required override init() {
    }

    func isEnabled() -> Bool {
        return true
    }

    func registerForPushKit() {
        newCXProvider(UnbluClientConfiguration.callKitProviderIconResourceName)
        self.registry.delegate = self
        self.registry.desiredPushTypes = [.voIP]
    }

    func newCXProvider(_ iconName: String?) {
        if #available(iOS 14.0, *) {
            guard LoggingCallKitProvider.provider == nil else {
                return
            }

            let config = CXProviderConfiguration()
            config.supportsVideo = true
            config.maximumCallsPerCallGroup = 2
            config.maximumCallGroups = 1
            config.supportedHandleTypes = [.generic, .phoneNumber]

            if let name = iconName {
                if let iconImage = UIImage(named: name) {
                    config.iconTemplateImageData = iconImage.pngData()
                }
            }

            LoggingCallKitProvider.provider = CXProvider(configuration: config)
            LoggingCallKitProvider.provider?.setDelegate(self, queue: nil)
        }
    }

    func endIncomingCall(with call: UUID, _ unanswered: Bool) {
        let cxCallController = CXCallController()
        let endCallAction = CXEndCallAction(call: call)
        let transaction = CXTransaction(action: endCallAction)
        cxCallController.request(transaction) { error in
            if let error = error {
                LoggingCallKitProvider.provider?.reportCall(with: call, endedAt: Date(), reason: unanswered ? .unanswered : .remoteEnded)
                return
            }
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        UnbluNotificationApi.instance.pushRegistry(payload: payload.dictionaryPayload, completion: completion)
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        appLog.notice("UnbluDemo [CallKitProvider] CXAnswerCallAction: \(action.callUUID.uuidString, privacy: .public)")
        action.fulfill()
        UnbluNotificationApi.instance.provider(answerCallUUID: action.callUUID)
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        appLog.notice("UnbluDemo [CallKitProvider] CXStartCallAction: \(action.callUUID.uuidString, privacy: .public)")
        action.fulfill()
        LoggingCallKitProvider.provider?.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        LoggingCallKitProvider.provider?.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
    }

    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        appLog.notice("UnbluDemo [CallKitProvider] CXEndCallAction: \(action.callUUID.uuidString, privacy: .public)")
        action.fulfill()
        UnbluNotificationApi.instance.provider(endCallUUID: action.callUUID)
    }

    func providerDidReset(_ provider: CXProvider) {
        UnbluNotificationApi.instance.providerDidReset()
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        UnbluNotificationApi.instance.pushRegistry(token: token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        UnbluNotificationApi.instance.pushRegistryInvalidate()
    }
}

extension LoggingCallKitProvider {

    private func isPhoneNumber(_ phone: String) -> Bool {
        var phoneNumber = phone
        let removeCharacters: Set<Character> = [" ", "-", "+"]
        phoneNumber.removeAll(where: { removeCharacters.contains($0) })
        return phoneNumber.allSatisfy { $0.isNumber }
    }

    func reportNewIncomingCall(callId: UUID, handlerName: String, callType: String, _ completion: @escaping (Error?) -> Void) {
        let callUpdate = CXCallUpdate()
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.supportsHolding = false
        let generic = CXHandle(type: isPhoneNumber(handlerName) ? .phoneNumber : .generic, value: handlerName)
        callUpdate.remoteHandle = generic

        callUpdate.hasVideo = (callType == "VIDEO" ? true : false)

        LoggingCallKitProvider.provider?.reportNewIncomingCall(with: callId, update: callUpdate) { error in
            completion(error)
        }
    }

    func reportOutgoingCall(callId: UUID, handlerName: String, hasVideo: Bool) {
        newCXProvider(UnbluClientConfiguration.callKitProviderIconResourceName)

        let cxCallController = CXCallController()
        let handle = CXHandle(type: isPhoneNumber(handlerName) ? .phoneNumber : .generic, value: handlerName)
        let startCallAction = CXStartCallAction(call: callId, handle: handle)
        startCallAction.isVideo = hasVideo
        let transaction = CXTransaction(action: startCallAction)

        cxCallController.request(transaction) { error in
            if let error = error {
                appLog.notice("UnbluDemo [CallKitProvider] Failed to report outgoing call: \(String(describing: error), privacy: .public)")
                LoggingCallKitProvider.provider?.reportCall(with: callId, endedAt: Date(), reason: .failed)
                return
            }
        }
    }

    func reportUnsuccessfulCall(_ uuid: UUID, _ completion: @escaping () -> Void) {
        LoggingCallKitProvider.provider?.reportNewIncomingCall(with: uuid, update: CXCallUpdate(), completion: { error in
            completion()
            self.endIncomingCall(with: uuid, true)
        })
    }
}

extension LoggingCallKitProvider {

    func getCountryCode() -> String? {
        var countryCode: String? = nil
        let locale = Locale.current
        if #available(iOS 16, *) {
            if let value = locale.region?.identifier {
                countryCode = value
            }
        } else {
            if let value = locale.regionCode {
                countryCode = value
            }
        }
        appLog.notice("UnbluDemo [CallKitProvider] Current country code: \(String(describing: countryCode), privacy: .public)")
        return countryCode
    }

    func isCallKitSupported() -> Bool {
        guard let countryCode = getCountryCode() else { return true }
        if countryCode.contains("CN") ||
            countryCode.contains("CHN") {
            return false
        }
        return true
    }
}
