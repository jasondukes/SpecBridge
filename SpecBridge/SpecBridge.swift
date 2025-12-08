import Foundation
import Combine
import AVFoundation
import HaishinKit
import RTMPHaishinKit

@MainActor
class TwitchManager: ObservableObject {
    // The connection to the Twitch Server
    private var rtmpConnection = RTMPConnection()
    // The stream object that sends the data (Now an Actor in v2.0)
    private var rtmpStream: RTMPStream!
    
    @Published var isBroadcasting = false
    @Published var connectionStatus = "Disconnected"
    
    init() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
    }
    
    func startBroadcast(streamKey: String) async {
        let twitchURL = "rtmp://live.twitch.tv/app"
        connectionStatus = "Connecting..."
        
        do {
            try await rtmpConnection.connect(twitchURL)
            try await rtmpStream.publish(streamKey)
            connectionStatus = "Live on Twitch!"
            isBroadcasting = true
        } catch {
            connectionStatus = "Connection Failed: \(error.localizedDescription)"
            isBroadcasting = false
        }
    }
    
    func stopBroadcast() async {
        do {
            try await rtmpConnection.close()
        } catch {
            print("Error closing stream: \(error)")
        }
        isBroadcasting = false
        connectionStatus = "Disconnected"
    }
    
    // FIX: Handles the "Actor-isolated" error
    func processVideoFrame(_ buffer: CMSampleBuffer) {
        guard isBroadcasting else { return }
        
        Task {
            // We use 'try? await' to safely send data to the background streamer
            try? await rtmpStream.append(buffer)
        }
    }
}
