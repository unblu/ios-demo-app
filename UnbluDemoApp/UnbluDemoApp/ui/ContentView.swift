import SwiftUI
import UnbluCoreSDK

struct RepresentedUnbluView: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView {
        view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct LoginView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Unblu Demo")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button(action: onLogin) {
                Text("Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(40)
    }
}

struct ContentView: View {
    @State private var unbluView: UIView?
    @State private var isLoggedIn: Bool = false
    @State var tabSelection: Int = 1
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var uiState = AppDelegate.getUnbluUiState()

    var body: some View {
        Group {
            if isLoggedIn {
                mainView
            } else {
                LoginView {
                    isLoggedIn = true
                }
            }
        }
        .overlay(alignment: .top) {
            incomingCallBanner
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                appLog.notice("UnbluDemo [ContentView] pending call: \(UnbluNotificationApi.instance.hasPendingIncomingCall)")
            }
        }
    }

    private var mainView: some View {
        TabView(selection: $tabSelection) {
            unbluTab
                .tabItem {
                    Label("Unblu", systemImage: "house")
                }
                .tag(1)
                .navigationTitle("Unblu View")

            moreTab
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(2)
        }
        .onAppear {
            initializeUnbluClient()
        }
    }

    private var unbluTab: some View {
        ZStack(alignment: .topTrailing) {
            if let view = unbluView {
                RepresentedUnbluView(view: view)
                    .padding(1)
            } else {
                Text("Connecting...")
                    .foregroundColor(.gray)
            }
        }
    }

    @ViewBuilder
    private var incomingCallBanner: some View {
        if let event = uiState.lastIncomingCallEvent {
            Text(event)
                .font(.footnote.monospaced())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.black.opacity(0.85))
                .cornerRadius(10)
                .padding(.horizontal, 12)
                .onTapGesture {
                    uiState.lastIncomingCallEvent = nil
                }
        }
    }

    private var moreTab: some View {
        ZStack(alignment: .topTrailing) {
            Text("More...")
                .foregroundColor(.gray)
        }
    }

    private func initializeUnbluClient() {
        guard AppDelegate.createVisitorClient([]) else { return }
        AppDelegate.connectToUnbluServer {
            unbluView = AppDelegate.getUnbluUiState().unbluView
        }
    }
}

#Preview {
    ContentView()
}
