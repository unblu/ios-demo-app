//
//  VisitorClientDelegate.swift
//

import Foundation
import UnbluCoreSDK
import UnbluMobileCoBrowsingModule




///delegate for Unblu agent client to react to events. E.g. logout when the SDK reports that the user wants to hide the Unblu UI
class VisitorClientDelegate: UnbluVisitorClientDelegate {
    func unblu(updatedConversationInfos conversationInfos: [UnbluCoreSDK.ConversationInfo]) {
    }

    let unbluClient: UnbluClient
    var isInternalError = false

    init(_ unbluClient: UnbluClient) {
        self.unbluClient = unbluClient
    }

    func unblu(didUpdatePersonActivityInfo personActivity: PersonActivityInfo) {
    }

    func unbluDidInitialize() {
        appLog.notice("UnbluDemo [VisitorClientDelegate] unbluDidInitialize")
    }

    func unbluDidDeinitialize() {
        appLog.notice("UnbluDemo [VisitorClientDelegate] unbluDidDeinitialize")
    }

    func unblu(didUpdateAgentAvailability isAvailable: Bool) {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didUpdateAgentAvailability: \(isAvailable)")
    }

    func unblu(didUpdatePersonInfo personInfo: PersonInfo) {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didUpdatePersonInfo: \(String(describing: personInfo), privacy: .public)")
    }

    func unblu(didUpdateUnreadMessages count: Int) {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didUpdateUnreadMessages: \(count)")
    }

    func unblu(didChangeOpenConversation openConversation: UnbluConversation?) {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didChangeOpenConversation: \(String(describing: openConversation), privacy: .public)")
    }

    func didHideModalUi() {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didHideModalUi")
    }

    func unblu(didRequestHideUi reason: UnbluUiHideRequestReason, conversationId: String?)  {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didRequestHideUi: \(String(describing: reason), privacy: .public), conversationId: \(String(describing: conversationId), privacy: .public)")
    }

    func unblu(didToggleCallUi isOpen: Bool) {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didToggleCallUi: \(isOpen)")
    }


    func unblu(didRequestShowUi withReason: UnbluUiRequestReason, requestedByUser: Bool)  {
        appLog.notice("UnbluDemo [VisitorClientDelegate] didRequestShowUi: \(String(describing: withReason), privacy: .public)")
    }

    func handleActiveConversationButtonClick() -> UnbluCoreSDK.ButtonInterceptorAction {
        appLog.notice("UnbluDemo [VisitorClientDelegate] handleActiveConversationButtonClick")
        return .useInternalHandler
    }

    func handleUnbluCollapsed() -> ButtonInterceptorAction {
        appLog.notice("UnbluDemo [VisitorClientDelegate] handleUnbluCollapsed")
        return .useInternalHandler
    }


    func unblu(didReceiveError type: UnbluClientErrorType, description: String) {
    }
}





