import Foundation
import SwiftUI
import Combine
import UIKit
import AVFoundation
import MWDATCore
import MWDATCamera

@MainActor
class StreamManager: ObservableObject {
    @Published var currentFrame: UIImage?
    @Published var status = "Ready to Stream"
    @Published var isStreaming = false
    
    private var streamSession: StreamSession?
    private var token: AnyListenerToken?
    
    // Reference to Twitch Manager
    var twitchManager: TwitchManager?
    
    private func configureAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Sets iOS to allow Bluetooth audio (prevents "Video Paused" error)
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try session.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func startStreaming() async {
        status = "Checking permissions..."
        
        let currentStatus = try? await Wearables.shared.checkPermissionStatus(.camera)
        if currentStatus != .granted {
            status = "Requesting permission..."
            let requestResult = try? await Wearables.shared.requestPermission(.camera)
            if requestResult != .granted {
                status = "Permission denied. Check Meta AI app."
                return
            }
        }
        
        status = "Configuring Audio..."
        configureAudio()
        
        status = "Configuring session..."
        let selector = AutoDeviceSelector(wearables: Wearables.shared)
        
        // Low resolution is often better for smooth live streaming latency
        let config = StreamSessionConfig(
            videoCodec: .raw,
            resolution: .low,
            frameRate: 24
        )
        
        let session = StreamSession(streamSessionConfig: config, deviceSelector: selector)
        self.streamSession = session
        
        // --- VIDEO HANDLING ---
        token = session.videoFramePublisher.listen { [weak self] frame in
            // 1. Create the visual image for the iPhone screen
            if let image = frame.makeUIImage() {
                Task { @MainActor in
                    self?.currentFrame = image
                    self?.status = "Streaming Live"
                    self?.isStreaming = true
                }
            }
            
            // 2. Extract the RAW buffer for Twitch
            // FIX: Accessed directly (no 'if let' needed for sampleBuffer)
            let buffer = frame.sampleBuffer
            
            // Hand off to TwitchManager (wrapped in Task to jump threads safely)
            Task { @MainActor in
                self?.twitchManager?.processVideoFrame(buffer)
            }
        }
        
        status = "Starting stream..."
        await session.start()
    }
    
    func stopStreaming() async {
        status = "Stopping..."
        await streamSession?.stop()
        
        // Ensure Twitch stops when glasses stop
        await twitchManager?.stopBroadcast()
        
        status = "Ready to Stream"
        isStreaming = false
        currentFrame = nil
    }
}
