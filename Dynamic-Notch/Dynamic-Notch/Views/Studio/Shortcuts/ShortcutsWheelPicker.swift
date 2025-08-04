//
//  ShortcutsWheelPicker.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/4/25.
//

import Foundation
import SwiftUI
import UserNotifications
import EventKit

struct ShortcutItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let label: String
    let action: ShortcutAction
    let color: Color
}

enum ShortcutAction {
    case doNotDisturb
    case recordMode
    case addEvent
    case pomodoroTimer
}

struct ShortcutWheelPicker: View {
    @State private var selectedIndex: Int = 0
    @State private var scrollPosition: Int?
    @State private var haptics: Bool = false
    @State private var byClick: Bool = false
    
    @State private var isDoNotDisturbActive: Bool = false
    @State private var isRecordingActive: Bool = false
    @State private var isPomodoroActive: Bool = false
    
    let shortcuts: [ShortcutItem] = [
        ShortcutItem(icon: "moon.fill", label: "Focus", action: .doNotDisturb, color: .blue),
        ShortcutItem(icon: "record.circle", label: "Record", action: .recordMode, color: .red),
        ShortcutItem(icon: "plus.circle.fill", label: "Add Event", action: .addEvent, color: .green),
        ShortcutItem(icon: "timer", label: "Timer", action: .pomodoroTimer, color: .orange)
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Wheel picker
            wheelPicker
        }
        .frame(width: 140)
    }
    
    //    private var selectedShortcutView: some View {
    //        VStack(spacing: 8) {
    //            ZStack {
    //                // Gear background
    //                Image(systemName: "gear")
    //                    .font(.title)
    //                    .foregroundStyle(.gray.opacity(0.3))
    //                    .scaleEffect(1.5)
    //                    .rotationEffect(.degrees(Double(selectedIndex * 45)))
    //                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedIndex)
    //
    //                // Main icon
    //                Image(systemName: getIconForCurrentState())
    //                    .font(.system(size: 20))
    //                    .foregroundStyle(getActiveColor())
    //                    .fontWeight(.semibold)
    //                    .contentTransition(.symbolEffect)
    //            }
    //            .frame(width: 60, height: 60)
    //
    //            Text(shortcuts[selectedIndex].emoji + " " + shortcuts[selectedIndex].label)
    //                .font(.caption)
    //                .fontWeight(.medium)
    //                .foregroundStyle(.white)
    //                .multilineTextAlignment(.center)
    //                .lineLimit(2)
    //        }
    //        .padding(.horizontal, 8)
    //    }
    
    private var wheelPicker: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 4) {
                // Top spacers
                ForEach(0..<2, id: \.self) { _ in
                    Spacer().frame(height: 20).id(UUID())
                }
                
                // Shortcut items
                ForEach(shortcuts.indices, id: \.self) { index in
                    shortcutWheelItem(index: index)
                        .id(index)
                }
                .frame(maxWidth: .infinity)
                
                // Bottom spacers
                ForEach(0..<2, id: \.self) { _ in
                    Spacer().frame(height: 20).id(UUID())
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 120)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .scrollIndicators(.never)
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 1.0), trigger: haptics) // Customizing impact feedback
        .sensoryFeedback(.success, trigger: haptics) // Standard success feedback
        .sensoryFeedback(.alignment, trigger: haptics)
        .onChange(of: scrollPosition) { oldValue, newValue in
            if !byClick {
                handleScrollChange(newValue: newValue)
            } else {
                byClick = false
            }
        }
        .onAppear {
            scrollPosition = selectedIndex
        }
        .mask {
            // Gradient mask for fade effect
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                
                Rectangle()
                    .fill(.red)
                    .frame(height: 80)
                
                LinearGradient(
                    colors: [.black, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
            }
        }
    }
    
    private func shortcutWheelItem(index: Int) -> some View {
        let isSelected = index == selectedIndex
        let shortcut = shortcuts[index]
        
        return Button {
            selectedIndex = index
            byClick = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                scrollPosition = index
            }
            haptics.toggle()
            
            // 선택 시 바로 액션 실행
            executeSelectedAction()
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? shortcuts[index].color.opacity(0.2) : .gray.opacity(0.1))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: getIconForAction(shortcut.action))
                        .font(.caption)
                        .foregroundStyle(isSelected ? shortcuts[index].color : .gray)
                        .fontWeight(.medium)
                    
                }
                
                Text(shortcut.label)
                    .font(.system(size: 14))
                    .opacity(isSelected ? 1 : 0.6)
                

                Spacer(minLength: 0)
                
                if getActionActiveState(shortcut.action) {
                    Circle()
                        .fill(getActiveColor())
                        .frame(width: 4, height: 4) // 크기 줄임
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                //                    .fill(isSelected ? getActiveColor().opacity(0.1) : .clear)
                //                    .strokeBorder(isSelected ? getActiveColor().opacity(0.3) : .clear, lineWidth: 0.5)
                    .fill(isSelected ? shortcuts[index].color.opacity(0.1) : .clear)
                    .strokeBorder(isSelected ? shortcuts[index].color.opacity(0.3) : .clear, lineWidth: 0.5)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .scaleEffect(isSelected ? 1.05 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 30)
    }
    
//    private var actionButton: some View {
//        Button {
//            executeSelectedAction()
//            haptics.toggle()
//        } label: {
//            HStack {
//                Image(systemName: getActionButtonIcon())
//                    .font(.caption)
//                    .fontWeight(.semibold)
//
//                Text(getActionButtonText())
//                    .font(.caption)
//                    .fontWeight(.medium)
//            }
//            .foregroundStyle(.white)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)
//            .background(
//                Capsule()
//                    .fill(.blue)
//                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//        .scaleEffect(1.0)
//        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: selectedIndex)
//        .sensoryFeedback(.alignment, trigger: haptics)
//    }
    
    private func handleScrollChange(newValue: Int?) {
        guard let newIndex = newValue,
              newIndex >= 0,
              newIndex < shortcuts.count,
              newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        haptics.toggle()
    }
    
    private func getIconForCurrentState() -> String {
        let shortcut = shortcuts[selectedIndex]
        return getIconForAction(shortcut.action)
    }
    
    private func getIconForAction(_ action: ShortcutAction) -> String {
        switch action {
        case .doNotDisturb:
            return isDoNotDisturbActive ? "moon.fill" : "moon"
        case .recordMode:
            return isRecordingActive ? "stop.circle.fill" : "record.circle"
        case .addEvent:
            return "plus.circle.fill"
        case .pomodoroTimer:
            return isPomodoroActive ? "pause.circle.fill" : "timer"
        }
    }
    
    private func getActiveColor() -> Color {
        let shortcut = shortcuts[selectedIndex]
        switch shortcut.action {
        case .doNotDisturb:
            return isDoNotDisturbActive ? .blue : .gray
        case .recordMode:
            return isRecordingActive ? .red : .gray
        case .addEvent:
            return .green
        case .pomodoroTimer:
            return isPomodoroActive ? .orange : .gray
        }
    }
    
    private func getActionActiveState(_ action: ShortcutAction) -> Bool {
        switch action {
        case .doNotDisturb:
            return isDoNotDisturbActive
        case .recordMode:
            return isRecordingActive
        case .addEvent:
            return false // 이벤트 생성은 상태가 없음
        case .pomodoroTimer:
            return isPomodoroActive
        }
    }
    
    private func executeSelectedAction() {
        let shortcut = shortcuts[selectedIndex]
        switch shortcut.action {
        case .doNotDisturb:
            toggleDoNotDisturb()
        case .recordMode:
            toggleRecordMode()
        case .addEvent:
            addQuickEvent()
        case .pomodoroTimer:
            togglePomodoroTimer()
        }
    }
    
    // MARK: - Action Implementations
    
    private func toggleDoNotDisturb() {
        isDoNotDisturbActive.toggle()
        
        // TODO: 실제 시스템 DND 토글 구현
        // DoNotDisturbManager를 별도로 만들어서 처리
        print("DND toggled: \(isDoNotDisturbActive)")
    }
    
    private func toggleRecordMode() {
        isRecordingActive.toggle()
        
        if isRecordingActive {
            // TODO: ScreenRecordingManager를 통해 화면 녹화 시작
            print("Screen recording started")
        } else {
            // TODO: ScreenRecordingManager를 통해 화면 녹화 종료
            print("Screen recording stopped")
        }
    }
    
    private func addQuickEvent() {
        // TODO: EventManager를 통해 빠른 이벤트 생성
        print("Quick event creation triggered")
    }
    
    private func togglePomodoroTimer() {
        isPomodoroActive.toggle()
        
        if isPomodoroActive {
            // TODO: PomodoroManager를 통해 타이머 시작
            print("Pomodoro timer started")
        } else {
            // TODO: PomodoroManager를 통해 타이머 종료
            print("Pomodoro timer stopped")
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea(.all)
        
        ShortcutWheelPicker()
            .padding()
            .background(Color.black)
            .frame(width: 500, height: 400)
    }
}
