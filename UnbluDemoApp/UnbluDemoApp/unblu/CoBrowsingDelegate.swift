import Foundation
import UnbluMobileCoBrowsingModule
import UnbluCoreSDK

class CoBrowsingDelegate : UnbluMobileCoBrowsingModuleDelegate {
    var unbluClient: UnbluClient?

    init(_ unbluClient: UnbluClient) {
        self.unbluClient = unbluClient
    }
    
    func unbluMobileCoBrowsingModuleHandleButtonClick(_ unbluMobileCoBrowsingModuleApi: any UnbluMobileCoBrowsingModule.UnbluMobileCoBrowsingModuleApi) -> ButtonInterceptorAction {
        return .useInternalHandler
    }
    
    func unbluMobileCoBrowsingModuleDidStartCoBrowsing(_ unbluMobileCoBrowsingModuleApi: UnbluMobileCoBrowsingModuleApi) {
    }
    
    func unbluMobileCoBrowsingModuleDidStopCoBrowsing(_ unbluMobileCoBrowsingModuleApi: UnbluMobileCoBrowsingModuleApi) {
    }
}
