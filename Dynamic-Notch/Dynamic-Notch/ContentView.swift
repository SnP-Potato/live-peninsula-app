//
//  ContentView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/11/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: NotchViewModel
   
    @ObservedObject var coordinaotr = Coordinator.shared
    
}

