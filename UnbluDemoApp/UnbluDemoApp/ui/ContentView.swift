import SwiftUI

struct RepresentedUnbluView: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView {
        view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ContentView: View {
    @State private var unbluView: UIView?
    @State var tabSelection: Int = 1

    var body: some View {
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
