//
//  SpecBridgeApp.swift
//  SpecBridge
//
//  Created by Jason Dukes on 12/5/25.
//

import SwiftUI
import MWDATCore

@main
struct SpecBridgeApp: App {
    
    init() {
        try? Wearables.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
