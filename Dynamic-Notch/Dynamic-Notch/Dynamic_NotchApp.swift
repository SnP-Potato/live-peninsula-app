//
//  Dynamic_NotchApp.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import SwiftUI

@main
struct Dynamic_NotchApp: App {
    var body: some Scene {
        MenuBarExtra("DynamicNoych", systemImage: "person.fill")
        {
            SettingsLink(label: {
                Text("Setting")
            })
            .keyboardShortcut(".", modifiers: .command)
            
            Button(action: {
                NSApp.terminate(nil) //종료하는 것
            }, label: {
                Text("Quit")
            })
            .keyboardShortcut("Q", modifiers: .command)
        }
    }
}
