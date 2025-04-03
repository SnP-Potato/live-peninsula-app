//
//  NotchViewModel.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import Defaults
import Combine
import SwiftUI

class NotchViewModel: NSObject, ObservableObject {
    @ObservedObject var coordinator = Coordinator.shared
    
    let animationManager: AnimationManager = .init(style: .notch)
    let animation: Animation?
    
    @Published var mainView: NotchMainFeaturesView = .home
    @Published private(set) var notchState: NotchStatus = .off
    
    var screen: String?
    
    @Published var notchSize: CGSize = offNotchSize()
    @Published var closedNotchSize: CGSize = offNotchSize() 
    
    
}
