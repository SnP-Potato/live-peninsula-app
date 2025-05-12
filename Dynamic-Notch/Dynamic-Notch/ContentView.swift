//
//  ContentView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/11/25.
//

import SwiftUI
import Combine
import AVFoundation
import Defaults

struct ContentView: View {
    @EnvironmentObject var vm: NotchViewModel //노치의 상태와 크기 관리 open(), close()
    @ObservedObject var coordinator = Coordinator.shared
    
    @State private var hoverTime: Date?
    @State private var Hovering: Bool = false
    @State private var hoverAnimation: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
        }
    }
    
    @ViewBuilder
    func notchLayout() -> some View {
        VStack(alignment: .leading) {
            if coordinator.firstLaunch {
                Spacer()
                
                // MARK: Hello Animation추가 예정
                // HelloAnimation()
                
                Spacer().animation(.spring(.bouncy(duration: 0.4)), value: coordinator.firstLaunch)
            } else {
                
            }
        }
    }
    
}

