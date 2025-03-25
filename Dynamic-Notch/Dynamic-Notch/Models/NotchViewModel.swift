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
    
    let animation: Animation? = nil
    
    @Published var mainView: NotchMainFeaturesView = .home
    @Published private(set) var notchState: NotchStatus = .off
}
