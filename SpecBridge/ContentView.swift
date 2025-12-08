import SwiftUI
import MWDATCore

struct ContentView: View {
    // This automatically saves "twitch_key" to the phone's storage
    @AppStorage("twitch_key") private var twitchStreamKey: String = ""
    
    // Our managers
    @StateObject private var streamManager = StreamManager()
    @StateObject private var twitchManager = TwitchManager()
    
    var body: some View {
        Group {
            if twitchStreamKey.isEmpty {
                // 1. SETUP SCREEN
                SetupView(streamKey: $twitchStreamKey)
            } else {
                // 2. STREAMING SCREEN
                StreamingView(
                    streamManager: streamManager,
                    twitchManager: twitchManager,
                    streamKey: twitchStreamKey,
                    onLogout: {
                        twitchStreamKey = ""
                    }
                )
            }
        }
        .onAppear {
            // Link the two managers together
            streamManager.twitchManager = twitchManager
        }
        .onOpenURL { url in
            Task { try? await Wearables.shared.handleUrl(url) }
        }
    }
}

// --- SUB-VIEW: SETUP ---
struct SetupView: View {
    @Binding var streamKey: String
    @State private var inputKey = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Setup Twitch")
                .font(.largeTitle).bold()
            
            TextField("Enter Stream Key", text: $inputKey)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Connect to Meta Glasses") {
                try? Wearables.shared.startRegistration()
            }
            .buttonStyle(.bordered)
            
            Button("Save & Continue") {
                if !inputKey.isEmpty {
                    streamKey = inputKey
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputKey.isEmpty)
        }
        .padding()
    }
}

// --- SUB-VIEW: STREAMING ---
struct StreamingView: View {
    @ObservedObject var streamManager: StreamManager
    @ObservedObject var twitchManager: TwitchManager
    var streamKey: String
    var onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Video Preview
            ZStack {
                Color.black
                if let videoImage = streamManager.currentFrame {
                    Image(uiImage: videoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Glasses Offline").foregroundStyle(.gray)
                }
            }
            .frame(height: 500)
            .cornerRadius(12)
            
            // Status Info
            VStack {
                Text("Glasses: \(streamManager.status)")
                Text("Twitch: \(twitchManager.connectionStatus)")
                    .bold()
                    .foregroundStyle(twitchManager.isBroadcasting ? .green : .red)
            }
            
            HStack {
                Button(streamManager.isStreaming ? "Stop All" : "Go Live") {
                    Task {
                        if streamManager.isStreaming {
                            await streamManager.stopStreaming()
                            await twitchManager.stopBroadcast()
                        } else {
                            // Start Glasses
                            await streamManager.startStreaming()
                            // Start Twitch
                            await twitchManager.startBroadcast(streamKey: streamKey)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(streamManager.isStreaming ? .red : .green)
                
                Button("Logout") {
                    onLogout()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
