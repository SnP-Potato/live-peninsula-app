//
//  SwipeableDateSelector.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import SwiftUI

struct DatePickerConfiguration {
    let pastDays: Int = 7  //  전 7일
    let futureDays: Int = 7 // 후 7일
    let animationDuration: Double = 0.4
    let swipeThreshold: CGFloat = 50.0
}


// MARK: - 톱니바퀴 날짜 선택기
struct SwipeableDateSelector: View {
    @Binding var currentDate: Date
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var isExpanded: Bool = false // 펼침 상태
    @State private var selectedIndex: Int = 0
    @State private var scrollPosition: Int?
    @State private var hapticFeedback = false
    @State private var byClick: Bool = false
    
    @State private var dateUpdateTimer: Timer?
    @State private var todayDate: Date = Date()
    
    private let config = DatePickerConfiguration()
    
    // 날짜 배열 생성 (과거 7일 + 오늘 + 미래 7일)
    private var dateArray: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: todayDate)
        
        var dates: [Date] = []
        
        // 과거 날짜들
        for i in (1...config.pastDays).reversed() {
            if let pastDate = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(pastDate)
            }
        }
        
        // 오늘
        dates.append(today)
        
        // 미래 날짜들
        for i in 1...config.futureDays {
            if let futureDate = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(futureDate)
            }
        }
        
        return dates
    }
    
    // 유효한 인덱스 범위
    private var validIndexRange: ClosedRange<Int> {
        0...(dateArray.count - 1)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // 월 표시
            Text(calendarManager.formattedMonth.uppercased())
                .font(.system(size: 19, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(height: 40)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id("month-\(calendarManager.formattedMonth)")
            
            Spacer()
                .frame(height: 5)
            
            // 날짜 선택 영역
            ZStack {
                if isExpanded {
                    // 펼쳐진 상태: 가로 스크롤 휠
                    dateWheelPicker
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                } else {
                    // 접힌 상태: 오늘 날짜만 표시
                    singleDateDisplay
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.2).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                }
            }
            .frame(width: 90, height: 60)
            
            Spacer()
                .frame(height: 20)
        }
        .frame(width: 60, height: 130)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticFeedback)
        .onAppear {
            setupDateUpdateTimer() // ✅ 날짜 업데이트 타이머 설정
            initializeSelectedIndex()
        }
        .onDisappear {
            dateUpdateTimer?.invalidate() // ✅ 타이머 정리
        }
        .onChange(of: currentDate) { _, _ in
            initializeSelectedIndex()
        }
        .onChange(of: todayDate) { _, newTodayDate in
            print("오늘 날짜 업데이트: \(newTodayDate)")
            
            // 현재 선택된 날짜가 어제였다면 오늘로 자동 업데이트
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: newTodayDate)!
            if Calendar.current.isDate(currentDate, inSameDayAs: yesterday) {
                print("어제 날짜였음 - 오늘로 자동 업데이트")
                currentDate = newTodayDate
            }
            
            initializeSelectedIndex()
        }
    }
    
    // MARK: - 단일 날짜 표시 (접힌 상태)
    private var singleDateDisplay: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
            hapticFeedback.toggle()
        } label: {
            ZStack {
                
                // 현재 선택된 날짜
                DateDisplayCard(date: currentDate)
                    .scaleEffect(1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 가로 휠 피커 (펼쳐진 상태)
    private var dateWheelPicker: some View {
        VStack(spacing: 8) {
            
            // 스크롤 휠
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    // 좌측 스페이서 (충분한 여백 확보)
                    Spacer().frame(width: 45).id("leftSpacer")
                    
                    // 날짜 아이템들만 - 스페이서 제거
                    ForEach(dateArray.indices, id: \.self) { index in
                        dateWheelItem(index: index)
                            .id("date-\(index)")
                    }
                    
                    // 우측 스페이서 (충분한 여백 확보)
                    Spacer().frame(width: 45).id("rightSpacer")
                }
                .scrollTargetLayout()
            }
            .frame(width: 90, height: 55)
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .scrollClipDisabled(false) // 🚨 스크롤 클리핑 활성화
            .scrollTargetBehavior(.viewAligned) // 🚨 뷰 정렬 동작 강제
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 1.0), trigger: hapticFeedback)
            .sensoryFeedback(.success, trigger: hapticFeedback)
            .sensoryFeedback(.alignment, trigger: hapticFeedback)
            .onChange(of: scrollPosition) { oldValue, newValue in
                if !byClick {
                    handleScrollChange(oldValue: oldValue, newValue: newValue)
                } else {
                    byClick = false
                }
            }
            .mask {
                // 좌우 그라데이션 마스크
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [.clear, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 15)
                    
                    Rectangle()
                        .fill(.black)
                        .frame(width: 60)
                    
                    LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 15)
                }
            }
        }
    }
    
    private func dateWheelItem(index: Int) -> some View {
        let isSelected = index == selectedIndex
        let date = dateArray[index]
        
        return Button {
            selectedIndex = index
            currentDate = date
            byClick = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                scrollPosition = index
            }
            hapticFeedback.toggle()
            
            // 선택 후 잠시 후 자동으로 접기
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded = false
                }
            }
        } label: {
            DateDisplayCard(date: date)
                .scaleEffect(isSelected ? 1.0 : 0.7)
                .opacity(isSelected ? 1.0 : 0.5)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 25)
    }
    
    private func handleScrollChange(oldValue: Int?, newValue: Int?) {
        // 유효하지 않은 scrollPosition인 경우 처리
        guard let newIndex = newValue else {
            // scrollPosition이 nil인 경우 현재 선택을 유지
            DispatchQueue.main.async {
                self.scrollPosition = self.selectedIndex
            }
            return
        }
        
        // 스페이서 영역의 인덱스인지 확인 (실제 날짜 배열 범위를 벗어나는 경우)
        guard validIndexRange.contains(newIndex) else {
            // 범위를 벗어난 인덱스인 경우 강제로 이전 유효한 위치로 되돌리기
            let fallbackIndex = oldValue ?? selectedIndex
            
            DispatchQueue.main.async {
                // 이전 유효한 위치나 현재 선택된 위치로 되돌리기
                if self.validIndexRange.contains(fallbackIndex) {
                    self.scrollPosition = fallbackIndex
                } else {
                    self.scrollPosition = self.selectedIndex
                }
                
                // 햅틱 피드백으로 경계에 도달했음을 알림
                self.hapticFeedback.toggle()
            }
            
            // currentDate는 절대 업데이트하지 않음 (월 변경 방지)
            return
        }
        
        // 동일한 인덱스인 경우 업데이트하지 않음
        guard newIndex != selectedIndex else { return }
        
        // 유효한 범위 내에서만 정상적인 업데이트
        DispatchQueue.main.async {
            self.selectedIndex = newIndex
            self.currentDate = self.dateArray[newIndex]
            self.hapticFeedback.toggle()
        }
    }
    
    private func setupDateUpdateTimer() {
            // 30초마다 현재 날짜 체크 (자정 근처에서 빠르게 감지)
            dateUpdateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                let newToday = Calendar.current.startOfDay(for: Date())
                if !Calendar.current.isDate(todayDate, inSameDayAs: newToday) {
                    print("📅 SwipeableDateSelector: 날짜 변경 감지")
                    DispatchQueue.main.async {
                        todayDate = newToday
                    }
                }
            }
        }
    
    private func initializeSelectedIndex() {
        let calendar = Calendar.current
        
        // 현재 선택된 날짜와 가장 가까운 인덱스 찾기
        for (index, date) in dateArray.enumerated() {
            if calendar.isDate(currentDate, inSameDayAs: date) {
                selectedIndex = index
                if isExpanded {
                    scrollPosition = index
                }
                return
            }
        }
        
        // 찾지 못했다면 오늘로 설정
        let todayIndex = config.pastDays // 오늘의 인덱스
        
        // 오늘 인덱스가 유효한 범위 내에 있는지 확인
        let validTodayIndex = max(validIndexRange.lowerBound, min(validIndexRange.upperBound, todayIndex))
        
        selectedIndex = validTodayIndex
        if isExpanded {
            scrollPosition = validTodayIndex
        }
        currentDate = dateArray[validTodayIndex]
    }
}


struct DateDisplayCard: View {
    let date: Date
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var currentTime = Date() // 실시간 시간 추적
    
    var body: some View {
        VStack(spacing: 2) {
            // 요일
            Text(dayOfWeekText(for: date))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isToday(date) ? .blue : .white)
                .frame(height: 16)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            
            // 날짜
            ZStack {
                Circle()
                    .fill(isToday(date) ? .blue.opacity(0.2) : .clear)
                    .frame(width: 30, height: 30)
                
                Text(dayText(for: date))
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(isToday(date) ? .blue : .white)
            }
            .frame(width: 36, height: 36)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 1.2).combined(with: .opacity)
            ))
        }
        .frame(width: 90, height: 54, alignment: .center)
        .padding(.horizontal)
        .onAppear {
            startTimeUpdater()
        }
        .onDisappear {
            // 타이머 정리는 자동으로 됨
        }
    }
    
    private func startTimeUpdater() {
        // 30초마다 현재 시간 업데이트
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        // currentTime을 사용해서 실시간 비교
        Calendar.current.isDate(date, inSameDayAs: currentTime)
    }
    
    // 나머지 함수들은 동일...
    private func dayOfWeekText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func dayText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
