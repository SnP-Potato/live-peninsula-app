//
//  SwipeableDateSelector.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import SwiftUI

// MARK: - 스와이프 가능한 날짜 선택기 설정
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
    
    private let config = DatePickerConfiguration()
    
    // 날짜 배열 생성 (과거 7일 + 오늘 + 미래 7일)
    private var dateArray: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
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
    
    var body: some View {
        VStack(spacing: 2) {
            // 월 표시
            Text(calendarManager.formattedMonth.uppercased())
                .font(.system(size: 19, weight: .black))
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
            initializeSelectedIndex()
        }
        .onChange(of: currentDate) { _, _ in
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
                    // 좌측 스페이서
                    ForEach(0..<2, id: \.self) { _ in
                        Spacer().frame(width: 15).id(UUID())
                    }
                    
                    // 날짜 아이템들
                    ForEach(dateArray.indices, id: \.self) { index in
                        dateWheelItem(index: index)
                            .id(index)
                    }
                    
                    // 우측 스페이서
                    ForEach(0..<2, id: \.self) { _ in
                        Spacer().frame(width: 15).id(UUID())
                    }
                }
                .scrollTargetLayout()
            }
            .frame(width: 90, height: 55)
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 1.0), trigger: hapticFeedback) // Customizing impact feedback
            .sensoryFeedback(.success, trigger: hapticFeedback) // Standard success feedback
            .sensoryFeedback(.alignment, trigger: hapticFeedback)
            .onChange(of: scrollPosition) { oldValue, newValue in
                if !byClick {
                    handleScrollChange(newValue: newValue)
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
    
    private func handleScrollChange(newValue: Int?) {
            // scrollPosition이 유효한 날짜 인덱스인지 확인
            guard let newIndex = newValue,
                  newIndex >= 0,
                  newIndex < dateArray.count,
                  newIndex != selectedIndex else {
                // 유효하지 않은 인덱스일 경우 현재 선택을 유지하고 스크롤을 원래 위치로 되돌림
                DispatchQueue.main.async {
                    self.scrollPosition = self.selectedIndex
                }
                return
            }
            
            DispatchQueue.main.async {
                self.selectedIndex = newIndex
                self.currentDate = self.dateArray[newIndex]
                self.hapticFeedback.toggle()
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
        selectedIndex = todayIndex
        if isExpanded {
            scrollPosition = todayIndex
        }
        currentDate = dateArray[todayIndex]
    }
}
// MARK: - 날짜 표시 카드
struct DateDisplayCard: View {
    let date: Date
    @EnvironmentObject var calendarManager: CalendarManager // CalendarManager 추가
    
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
    }
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
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
}


#Preview {
    SwipeableDateSelector(currentDate: .constant(Date()))
        .environmentObject(CalendarManager.shared)
        .frame(width: 500, height: 300)
}
