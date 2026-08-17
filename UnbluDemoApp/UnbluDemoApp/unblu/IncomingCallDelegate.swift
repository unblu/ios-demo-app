
import UnbluCoreSDK


class IncomingCallDelegate : UnbluIncomingCallDelegate {
    
    func unbluNotificationApi(_ api: UnbluNotificationApi,
                              didAcceptIncomingCallFor conversationId: String,
                              callType: String,
                              caller: String) {
        showInUi("Accepted call\nconversationId: \(conversationId)\ncallType: \(callType)\ncaller: \(caller)")
        guard !AppDelegate.unbluClient.useCustomCallKitProvider else { return }
        appLog.notice("UnbluDemo [IncomingCallDelegate] accepted call, conversationId: \(conversationId, privacy: .public), callType: \(callType, privacy: .public), caller: \(caller, privacy: .public)")
    }


    func unbluNotificationApi(_ api: UnbluNotificationApi,
                              didDeclineIncomingCallFor conversationId: String) {
        showInUi("Declined call\nconversationId: \(conversationId)")
        guard !AppDelegate.unbluClient.useCustomCallKitProvider else { return }
        appLog.notice("UnbluDemo [IncomingCallDelegate] declined call, conversationId: \(conversationId, privacy: .public)")
    }

    private func showInUi(_ text: String) {
        DispatchQueue.main.async {
            AppDelegate.getUnbluUiState().lastIncomingCallEvent = text
        }
    }
}
