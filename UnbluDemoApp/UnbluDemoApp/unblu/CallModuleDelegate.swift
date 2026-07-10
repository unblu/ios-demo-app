import Foundation
import UnbluCoreSDK

class CallModuleDelegate: UnbluCallModuleDelegate {
    
    var unbluClient: UnbluClient?
    
    init(_ unbluClient: UnbluClient) {
        self.unbluClient = unbluClient
    }
    
    func unbluMobileCallModuleHandlePiPButtonClick(_ unbluCallModuleApi: UnbluCallModuleApi) -> ButtonInterceptorAction {
        appLog.notice("UnbluDemo [CallModuleDelegate] handlePiPButtonClick")
        return .useInternalHandler
    }

    func unbluCallModuleDidStartCall(_ unbluCallModuleApi: UnbluCallModuleApi) {
        appLog.notice("UnbluDemo [CallModuleDelegate] didStartCall")
    }

    func unbluCallModuleDidEndCall(_ unbluCallModuleApi: UnbluCallModuleApi) {
        appLog.notice("UnbluDemo [CallModuleDelegate] didEndCall")
    }
    
}
