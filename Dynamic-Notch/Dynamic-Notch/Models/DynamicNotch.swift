//
//  DynamicNotch.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/30/25.
//

import Foundation
import SwiftUI

class DynamicNotch: ObservableObject {
    public var view: AnyView
    public var windowController: NSWindowController?
    
    @Published public var isVisible: Bool = false
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0
    @Published var notchStyle: NotchStyle = .notch
    
    private var timer: Timer?
    private let animationDuration: Double = 0.4
    
    private var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }
    
    public init(content: some View) {
        self.view = AnyView(content)
    }
}
