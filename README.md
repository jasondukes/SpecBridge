# SpecBridge

SpecBridge is an open-source iOS toolkit that connects Ray-Ban Meta smart glasses to RTMP streaming platforms. It serves as a bridge between the Meta Wearables Device Access Toolkit (DAT) and standard broadcasting protocols, allowing developers to build custom live-streaming experiences for smart glasses.

## Features
- **Live Video Bridge:** Routes raw video frames from Ray-Ban Meta glasses to an RTMP ingest server (Twitch, YouTube, Kick).
- **Audio Handling:** Manages iOS audio sessions to prevent Bluetooth disconnects during streaming.
- **Secure Auth:** Setup screen to input and store Stream Keys locally on the device.
- **Modern Swift:** Uses Swift Concurrency (async/await) and the Actor model for thread-safe streaming.

## Prerequisites

Before attempting to build this project, ensure you have the following:

### Hardware
- **Mac:** A Mac computer capable of running Xcode.
- **iPhone:** An iPhone running iOS 17.0 or later.
- **Smart Glasses:** Ray-Ban Meta Smart Glasses (Gen 2).

### Software & Accounts
- **Xcode 15+:** Required to compile the Swift code.
- **Meta View App:** Installed on your iPhone and paired with your glasses.
- **Twitch Account:** (Or other RTMP provider) to obtain your Stream Key.

### Important: Enable Developer Mode
You must enable Developer Mode on your glasses for them to communicate with third-party apps like SpecBridge.

1. Open the **Meta View** app on your iPhone.
2. Navigate to the **Devices** tab (Glasses icon).
3. Tap the **Gear icon** (Settings) > **General** > **About**.
4. Tap the **Version** number 5 times repeatedly.
5. A "Developer Mode" toggle will appear. Switch it to **ON**.

## Installation

This application is not available on the App Store. You must build and install it directly onto your iPhone using Xcode.

1. **Clone the Repository**
   Download the source code to your Mac.

2. **Open in Xcode**
   Double-click `SpecBridge.xcodeproj` to open the project.

3. **Resolve Dependencies**
   Xcode should automatically detect and fetch the required libraries (Meta Wearables DAT and HaishinKit).
   *Note: If errors appear, go to File > Packages > Resolve Package Versions.*

4. **Sign the App**
   - Click the "SpecBridge" project icon in the top-left sidebar.
   - Select the "SpecBridge" target in the center panel.
   - Go to the **Signing & Capabilities** tab.
   - Select your personal Apple ID under the "Team" dropdown.

5. **Deploy to iPhone**
   - Connect your iPhone to your Mac via USB.
   - Select your iPhone from the device list at the top of the Xcode window.
   - Click the **Run** (Play) button.

## Usage Guide

Once the app is running on your phone, follow this specific sequence to start a stream.

### 1. Connect to Glasses
- On the setup screen, tap **Connect**.
- The app will redirect you to the **Meta View** app.
- Accept the connection request in Meta View.
- You will be automatically redirected back to SpecBridge.
- *Verify:* The status indicator in SpecBridge should show "Connected".

### 2. Configure Stream Key
- Once connected, the Stream Key field will become active.
- Enter your **Twitch Stream Key** (found in your Twitch Creator Dashboard > Settings > Stream).
- Tap **Save & Continue**.

### 3. Start Streaming
- You will see the main dashboard with a camera preview placeholder.
- Tap **Go Live**.
- **Wait for Cues:**
  1. You will hear an audio prompt: "Experience Started".
  2. The LED on your glasses will turn on.
  3. The video feed will appear on your iPhone screen.
- After a few seconds, your stream will be live on Twitch.

### 4. Stop Streaming
- Tap **Stop All** in the app to end the broadcast.
- You will hear an audio prompt: "Experience Stopped".

## Troubleshooting

**"Connection Reset by Peer" / Stream disconnects immediately**
This usually means the stream key is invalid or the connection timed out. Ensure you have copied the correct key from your dashboard and that your internet connection is stable.

**Video is paused / Audio issues**
If the glasses pause the stream, it is usually because the iPhone stole the audio focus. This app manages the audio session automatically, but background apps (like Spotify or Calls) may interrupt the stream.

## Disclaimer

This project is an unofficial tool and is not affiliated with, endorsed by, or connected to Meta Platforms, Inc. or Twitch Interactive, Inc. "Ray-Ban Meta" is a trademark of Luxottica Group S.p.A. and Meta Platforms, Inc.

## License

MIT License. See LICENSE for details.