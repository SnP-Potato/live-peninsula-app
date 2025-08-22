//
//  ActionButton.swift
//  boringNotch
//
//  Created by PeterPark on 8/4/25.
//

import SwiftUI
import Defaults

// MARK: - Action Button Item
struct ActionButtonItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let activeIcon: String?
    let label: String
    let description: String
    let action: ActionButtonFunction
    let color: Color
    
    init(icon: String, activeIcon: String? = nil, label: String, description: String, action: ActionButtonFunction, color: Color) {
        self.icon = icon
        self.activeIcon = activeIcon
        self.label = label
        self.description = description
        self.action = action
        self.color = color
    }
}

// MARK: - Action Button Functions
enum ActionButtonFunction {
    case focusMode
    case addEvent
    case pomodoroTimer
    case none
}

// MARK: - Action Button View
struct ActionButtonView: View {
    @State private var selectedAction: ActionButtonFunction = .focusMode
    @State private var isPressed: Bool = false
    @State private var pressProgress: CGFloat = 0
    @State private var showActionSelection: Bool = false
    @State private var haptics: Bool = false
    
    // Action states
    @State private var isFocusModeActive: Bool = false
    @State private var isPomodoroActive: Bool = false
    
    // Press gesture
    @State private var pressWorkItem: DispatchWorkItem?
    
    let actionItems: [ActionButtonItem] = [
        ActionButtonItem(
            icon: "moon",
            activeIcon: "moon.fill",
            label: "Focus Mode",
            description: "Block distracting apps and\nnotifications for better focus.",
            action: .focusMode,
            color: .indigo
        ),
        ActionButtonItem(
            icon: "plus.circle",
            activeIcon: "plus.circle.fill",
            label: "Add Event",
            description: "Quickly add an event to\nyour calendar with one tap.",
            action: .addEvent,
            color: .green
        ),
        ActionButtonItem(
            icon: "timer",
            activeIcon: "pause.circle.fill",
            label: "Pomodoro Timer",
            description: "Start a focused work session\nwith the Pomodoro technique.",
            action: .pomodoroTimer,
            color: .orange
        )
    ]
    
    var selectedItem: ActionButtonItem {
        actionItems.first { $0.action == selectedAction } ?? actionItems[0]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showActionSelection {
                actionSelectionView
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8)),
                        removal: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.9))
                    ))
            }
            
            actionButton
        }
    }
    
    // MARK: - Main Action Button
    private var actionButton: some View {
        Button {
            // 짧은 탭은 액션 실행
            executeAction()
        } label: {
            ZStack {
                // Background circle
                Circle()
                    .fill(getButtonBackgroundColor())
                    .frame(width: 44, height: 44)
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .shadow(
                        color: getButtonShadowColor(),
                        radius: isPressed ? 8 : 4,
                        x: 0,
                        y: isPressed ? 4 : 2
                    )
                
                // Progress ring for long press
                if isPressed && pressProgress > 0 {
                    Circle()
                        .trim(from: 0, to: pressProgress)
                        .stroke(
                            selectedItem.color.opacity(0.8),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: pressProgress)
                }
                
                // Icon
                Image(systemName: getCurrentIcon())
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(getIconColor())
                    .contentTransition(.symbolEffect(.replace))
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        startLongPress()
                    }
                }
                .onEnded { _ in
                    endLongPress()
                }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: haptics)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocusModeActive)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPomodoroActive)
    }
    
    // MARK: - Action Selection View (iPhone Style)
    private var actionSelectionView: some View {
        VStack(spacing: 20) {
            Text("Action Button")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            
            // Main selection area with gear effect
            VStack(spacing: 24) {
                // Gear background with main icon
                ZStack {
                    // Rotating gear background
                    Image(systemName: "gear")
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.1))
                        .rotationEffect(.degrees(Double(getActionIndex() * 45)))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedAction)
                    
                    // Main action button (iPhone style oval)
                    ZStack {
                        // Oval background with glow
                        RoundedRectangle(cornerRadius: 40)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        selectedItem.color.opacity(0.8),
                                        selectedItem.color.opacity(0.6)
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 80, height: 140)
                            .shadow(color: selectedItem.color.opacity(0.4), radius: 20, x: 0, y: 0)
                            .overlay {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.2), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                    .frame(width: 80, height: 140)
                            }
                        
                        // Icon
                        Image(systemName: getCurrentIcon())
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .frame(height: 200)
                
                // Horizontal action selection scroll view
                VStack(spacing: 16) {
                    // Action selection dots
                    HStack(spacing: 8) {
                        ForEach(actionItems.indices, id: \.self) { index in
                            Circle()
                                .fill(selectedAction == actionItems[index].action ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(selectedAction == actionItems[index].action ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedAction)
                        }
                    }
                    
                    // Horizontal scroll picker
                    if #available(macOS 15.0, *) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 40) {
                                // Left spacer
                                Spacer()
                                    .frame(width: 100)
                                
                                // Action items
                                ForEach(actionItems.indices, id: \.self) { index in
                                    actionHorizontalItem(index: index)
                                        .id(index)
                                }
                                
                                // Right spacer
                                Spacer()
                                    .frame(width: 100)
                            }
                            .scrollTargetLayout()
                        }
                        .frame(height: 100)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: .constant(getActionIndex()), anchor: .center)
                        .onScrollPhaseChange { oldPhase, newPhase in
                            if newPhase == .idle && oldPhase == .interacting {
                                // 스크롤이 끝났을 때 중앙 정렬된 아이템 찾기
                                haptics.toggle()
                            }
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                // Title and description
                VStack(spacing: 8) {
                    Text(selectedItem.label)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .contentTransition(.numericText())
                    
                    Text(selectedItem.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .contentTransition(.interpolate)
                }
                .padding(.horizontal, 20)
                
                // Selection indicator (like photo mode)
                HStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(selectedItem.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.black.opacity(0.3))
                        .background(.ultraThinMaterial, in: Capsule())
                )
            }
            .frame(maxWidth: 280)
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.7))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Horizontal Action Item
    private func actionHorizontalItem(index: Int) -> some View {
        let isSelected = index == getActionIndex()
        let item = actionItems[index]
        
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedAction = item.action
            }
            haptics.toggle()
        } label: {
            VStack(spacing: 12) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(isSelected ? item.color.opacity(0.3) : .white.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .shadow(color: isSelected ? item.color.opacity(0.3) : .clear, radius: 8)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(isSelected ? item.color : .white.opacity(0.6))
                        .contentTransition(.symbolEffect(.replace))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Label
                Text(item.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
            }
            .frame(width: 90, height: 80)
            .scaleEffect(isSelected ? 1.0 : 0.85)
            .opacity(isSelected ? 1.0 : 0.6)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in }
        )
    }
    
    // MARK: - Helper Methods
    private func getActionIndex() -> Int {
        actionItems.firstIndex { $0.action == selectedAction } ?? 0
    }
    
    private func changeAction(direction: Int) {
        let currentIndex = getActionIndex()
        let newIndex = (currentIndex + direction + actionItems.count) % actionItems.count
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedAction = actionItems[newIndex].action
        }
        haptics.toggle()
    }
    
    private func startLongPress() {
        isPressed = true
        haptics.toggle()
        
        pressWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [self] in
            // 길게 누르기 완료 - 설정 화면 표시
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showActionSelection = true
            }
            haptics.toggle()
        }
        
        pressWorkItem = workItem
        
        // 프로그레스 애니메이션
        let startTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            guard isPressed else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / 0.8, 1.0) // 0.8초 길게 누르기
            
            DispatchQueue.main.async {
                pressProgress = progress
            }
            
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
                }
            }
        }
    }
    
    private func endLongPress() {
        pressWorkItem?.cancel()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isPressed = false
            pressProgress = 0
        }
        
        // 액션 선택 화면이 열려있으면 닫기
        if showActionSelection {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showActionSelection = false
                }
            }
        }
    }
    
    private func executeAction() {
        haptics.toggle()
        
        switch selectedAction {
        case .focusMode:
            toggleFocusMode()
        case .addEvent:
            addQuickEvent()
        case .pomodoroTimer:
            togglePomodoroTimer()
        case .none:
            break
        }
    }
    
    private func getCurrentIcon() -> String {
        switch selectedAction {
        case .focusMode:
            if isFocusModeActive, let activeIcon = selectedItem.activeIcon {
                return activeIcon
            }
            return selectedItem.icon
        case .pomodoroTimer:
            if isPomodoroActive, let activeIcon = selectedItem.activeIcon {
                return activeIcon
            }
            return selectedItem.icon
        case .addEvent:
            return selectedItem.icon
        case .none:
            return "questionmark"
        }
    }
    
    private func getButtonBackgroundColor() -> Color {
        switch selectedAction {
        case .focusMode:
            return isFocusModeActive ? selectedItem.color.opacity(0.8) : .white.opacity(0.1)
        case .pomodoroTimer:
            return isPomodoroActive ? selectedItem.color.opacity(0.8) : .white.opacity(0.1)
        default:
            return .white.opacity(0.1)
        }
    }
    
    private func getButtonShadowColor() -> Color {
        switch selectedAction {
        case .focusMode:
            return isFocusModeActive ? selectedItem.color.opacity(0.3) : .black.opacity(0.2)
        case .pomodoroTimer:
            return isPomodoroActive ? selectedItem.color.opacity(0.3) : .black.opacity(0.2)
        default:
            return .black.opacity(0.2)
        }
    }
    
    private func getIconColor() -> Color {
        switch selectedAction {
        case .focusMode:
            return isFocusModeActive ? .white : selectedItem.color
        case .pomodoroTimer:
            return isPomodoroActive ? .white : selectedItem.color
        default:
            return selectedItem.color
        }
    }
    
    // MARK: - Action Implementations
    private func toggleFocusMode() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isFocusModeActive.toggle()
        }
        
        // TODO: 실제 집중 모드 토글 구현
        print("Focus Mode toggled: \(isFocusModeActive)")
    }
    
    private func addQuickEvent() {
        // TODO: 빠른 이벤트 추가 구현
        print("Quick event creation triggered")
        
        // 일시적 피드백 애니메이션
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            // 버튼 애니메이션 효과
        }
    }
    
    private func togglePomodoroTimer() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isPomodoroActive.toggle()
        }
        
        // TODO: 포모도로 타이머 구현
        print("Pomodoro timer toggled: \(isPomodoroActive)")
    }
}

// MARK: - Preview
struct ActionButtonPreview: View {
    @State private var showSelection = true
    
    var body: some View {
        ZStack {
            // iPhone style background
            LinearGradient(
                colors: [
                    Color.black,
                    Color.gray.opacity(0.3),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Main preview with selection open
                ActionButtonView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // Auto show selection for preview
                        }
                    }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ActionButtonPreview()
}
