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
    }
    
    func unbluDidDeinitialize() {
    }
    
    func unblu(didUpdateAgentAvailability isAvailable: Bool) {
    }
    
    func unblu(didUpdatePersonInfo personInfo: PersonInfo) {
    }
    
    func unblu(didUpdateUnreadMessages count: Int) {
    }
    
    func unblu(didChangeOpenConversation openConversation: UnbluConversation?) {
    }

    func didHideModalUi() {
    }
    
    func unblu(didRequestHideUi reason: UnbluUiHideRequestReason, conversationId: String?)  {
    }
    
    func unblu(didToggleCallUi isOpen: Bool) {
    }
    
    
    func unblu(didRequestShowUi withReason: UnbluUiRequestReason, requestedByUser: Bool)  {

    }
    
    func handleActiveConversationButtonClick() -> UnbluCoreSDK.ButtonInterceptorAction {
        return .useInternalHandler
    }
    
    func handleUnbluCollapsed() -> ButtonInterceptorAction {
        return .useInternalHandler
    }

    
    func unblu(didReceiveError type: UnbluClientErrorType, description: String) {
    }
}





