
# Unblu SDK Demo Application

This application serves as a demonstration of the Unblu SDK's capabilities, showcasing the simplest method of integrating and utilizing the SDK.

It provides a foundation for reproducing potential issues or bugs and offers a framework for debugging and testing purposes.

Feel free to submit issues, feature requests, or pull requests to enhance the functionality of this demo application.


# General Unblu iOS Integration Guide

This guide will help you integrate Unblu into your iOS application.

The steps described below are implemented in this project. However, it is crucial to be aware of the most important step, which you must perform in every project that uses our SDK.

If any aspects are found to be missing, please review the project and code to check how it is configured.

## 1. Prerequisites

- **Apple Developer Account** (for provisioning and signing iOS apps).
- **Xcode** (latest stable version is recommended).
- **CocoaPods** or **Swift Package Manager (SPM)** for dependency management.
- **Unblu SDK Credentials** (e.g., API key, domain, environment details) provided by Unblu.
- **iOS 14 or later** (recommended minimum target).


## 2. Installation

### CocoaPods

#### **Install CocoaPods** (if not already installed):

```
sudo gem install cocoapods

```

#### Create or update your Podfile:

```
platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

workspace 'UnbluDemoApp'
project 'UnbluDemoApp.xcodeproj'

target 'UnbluDemoApp' do
  use_frameworks!
  pod 'WebRTC-SDK', '=104.5112.05'
end

```

Install pods:

```
pod install
```


### Swift Package Manager (SPM)

Starting with version 4.9.5, you should add a SwiftPM dependency to LiveKit’s webrtc-xcframework instead of using CocoaPods.

To do this in Xcode:

- Open your project/workspace in Xcode.
- Go to File "Add Packages…"
- In the Search or Enter Package URL field, enter:

```

https://github.com/livekit/webrtc-xcframework.git
```

- Choose the dependency version/rules (e.g., Up to Next Major, Exact, etc.) and then click Add Package.
- Make sure to select your target to link the LiveKit WebRTC XCFramework.

After adding the SPM dependency, you can remove any corresponding references to the WebRTC SDK in your Podfile to avoid duplication.

### Adding Unblu iOS SDK XCFrameworks

-	Open your Xcode project (or workspace).
-	Go to File » Add Packages… (again).
-	In the Search or Enter Package URL field, enter:

```
https://github.com/unblu/ios-sdk-xcframework
```


## 3. Project Configuration


### 3.1 Capabilities

1.	Push Notifications (Optional)
•	If you plan to receive in-app notifications for chats or calls, enable Push Notifications in Signing & Capabilities.
•	Add Background Modes if you want to handle these notifications while your app is in the background.
2.	Background Modes (Optional)
•	Enable Voice over IP or Audio, AirPlay, and Picture in Picture if you plan to support ongoing call sessions when the app enters the background.
3.	Keychain Access Groups (Optional)
•	If you’re using the service notification extension (see the documentation), you must add Keychain Access Groups and enable Keychain Sharing.

### 3.2 Info.plist Permissions & Keys

Since Unblu can utilize camera and microphone for video and audio calls, add the following usage descriptions to your Info.plist:

```
<key>NSCameraUsageDescription</key>
<string>This app requires camera access for video conferencing.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access for audio conversations.</string>
```

### 3.3 App Transport Security (ATS)

If your Unblu server uses non-HTTPS endpoints or special ports, update your Info.plist to allow these connections. For example:

```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```


## 4. Key Implementation Steps with Code


### 4.1	Create client configuration.
Here you configure specific client settings, including push notifications, whitelists and other related options.

```
let config = UnbluConfiguration()

```

### 4.2	Create the modules that will be used.
Here you can configure specific module settings and assign a delegate class to handle events related to the module.

```

let callModule = UnbluCallModuleProvider.create()
let coBrowsingConfig = MobileCoBrowsingConfiguration()
let coBrowsingModule = UnbluMobileCoBrowsingModuleProvider.create(config: coBrowsingConfig)

```

### 4.3	Register Modules.

```
config.register(module: callModule!)
config.register(module: coBrowsingModule!)
```

### 4.4	Create Client.

```
let unbluClient = Unblu.createVisitorClient(withConfiguration: config)
```

### 4.5	Start Client and wait for completion.
When the client starts, it attempts to load the initial JavaScript scripts and establish a connection via the JavaScript API to the collaboration server.
```
unbluClient.start { result in
    print(result.isSuccess ? "Client started" : "Failed to start")
}
```

### 4.6 Embed Unblu View into the UI
Usually, it is better to add the view after the client has started. The view is an Unblu container that extends UIView and contains an embedded WKWebView.
```
if let unbluView = unbluClient.view {
    someParentView.addSubview(unbluView)
}
```
