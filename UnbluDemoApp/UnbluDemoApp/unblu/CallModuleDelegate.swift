import Foundation
import UnbluCoreSDK

class CallModuleDelegate: UnbluCallModuleDelegate {
    
    var unbluClient: UnbluClient?
    
    init(_ unbluClient: UnbluClient) {
        self.unbluClient = unbluClient
    }
    
    func unbluMobileCallModuleHandlePiPButtonClick(_ unbluCallModuleApi: UnbluCallModuleApi) -> ButtonInterceptorAction {
        return .useInternalHandler
    }
    
    func unbluCallModuleDidStartCall(_ unbluCallModuleApi: UnbluCallModuleApi) {
    }
    
    func unbluCallModuleDidEndCall(_ unbluCallModuleApi: UnbluCallModuleApi) {
    }
    
}
