//
//  CalendarView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/29/25.
//

import SwiftUI
import EventKit


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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        guard let newIndex = newValue,
              newIndex >= 0,
              newIndex < dateArray.count,
              newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        currentDate = dateArray[newIndex]
        hapticFeedback.toggle()
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
    
    // MARK: - Helper Functions
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

// MARK: - 메인 캘린더 뷰
struct CalendarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var selectedDate = Date()
    
    var body: some View {
        HStack(spacing: 8) {
            // 왼쪽: 스와이프 가능한 날짜 선택기
            SwipeableDateSelector(currentDate: $selectedDate)
                .frame(width: 50, height: 130)
                .environmentObject(calendarManager) // CalendarManager 전달
            
            // 오른쪽: 해당 요일 이벤트
            ScrollView(.vertical, showsIndicators: false) {
                if calendarManager.accessStatus != .fullAccess {
                    NoAccessView()
                        .frame(width: 130)
                        .padding(.vertical, 12)
                } else if calendarManager.focusDayEvent.isEmpty {
                    EmptyEventView()
                } else {
                    LazyVStack(spacing: 0) {
                        // CalendarManager의 focusDayEvent를 직접 사용하고 정렬은 computed property로
                        ForEach(Array(sortedEvents.enumerated()), id: \.element.calendarItemIdentifier) { index, event in
                            EventRowView(
                                event: event,
                                lastEvent: index == sortedEvents.count - 1
                            )
                        }
                    }
                }
            }
            .frame(width: 120)
        }
        .frame(width: 170, height: 130)
        .onChange(of: selectedDate) { _, newDate in
            // CalendarManager의 updateFocusDate 사용
            calendarManager.updateFocusDate(newDate)
        }
        .onChange(of: calendarManager.focusDate) { _, newFocusDate in
            // CalendarManager의 focusDate와 동기화
            if selectedDate != newFocusDate {
                selectedDate = newFocusDate
            }
        }
        .onAppear {
            // CalendarManager의 focusDate로 초기화
            selectedDate = calendarManager.focusDate
            
            // CalendarManager의 기존 로직 사용
            Task {
                if calendarManager.accessStatus == .notDetermined {
                    await calendarManager.requestCalendarAccess()
                } else if calendarManager.accessStatus == .fullAccess {
                    calendarManager.loadTodayEvent() // CalendarManager의 함수 사용
                }
            }
        }
    }
    
    // CalendarManager의 focusDayEvent를 정렬하여 반환
    private var sortedEvents: [EKEvent] {
        calendarManager.focusDayEvent.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - 해당 요일 이벤트 부
struct EventRowView: View {
    let event: EKEvent
    let lastEvent: Bool
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private var isAllDay: Bool {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .day, for: event.startDate)?.contains(event.endDate) ?? false
        && calendar.component(.hour, from: event.startDate) == 0
        && calendar.component(.minute, from: event.startDate) == 0
    }
    
    private var eventColor: Color {
        if let cgColor = event.calendar.cgColor {
            return Color(cgColor)
        }
        return .blue
    }
    
    private var isEventFinished: Bool {
        Date() > event.endDate
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) { // alignment를 .firstTextBaseline로 변경
            
            // 캘린더 목록 색 추출
            VStack(spacing: 0) {
                // Circle을 제목과 같은 높이에 맞춤
                if isEventFinished {
                    Circle()
                        .strokeBorder(.green.opacity(0.5), lineWidth: 1)
//                        .opacity(0.5)
                        .frame(width: 9, height: 9)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold)) // ✅ font 크기로 조정
                                .foregroundColor(.green.opacity(0.8))
                        }
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 2 } // 약간 조정
                } else {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(/*eventColor*/.white.opacity(0.5), lineWidth: 1)
                        .frame(width: 8, height: 8)
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 2 } // 약간 조정
                }
                
                Spacer()
                
                // 연결선 - lastEvent가 아닐 때만 표시
                if !lastEvent {
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 1)
                        .frame(minHeight: 30)
                }
            }
            .frame(width: 12, alignment: .top)
            
            // 이벤트 제목, 기간, 위치
            VStack(alignment: .leading, spacing: 3) {
                // 이벤트 제목 - Circle과 같은 라인
                HStack {
                    Rectangle()
                        .fill(eventColor)
                        .cornerRadius(8)
                        .frame(width: 2, height: 10)
                    
                    Text(event.title ?? "제목 없음")
                        .font(.system(size: 10, weight: .thin))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -5,y: 1)
                }
                // 시간 표시
                HStack {
                    if isAllDay {
                        Text("All Day")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(eventColor)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(timeFormatter.string(from: event.startDate))
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text(timeFormatter.string(from: event.endDate))
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                
                // 위치 정보 (있을 경우)
                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arcade.stick")
                            .font(.system(size: 10))
                            .foregroundColor(eventColor)
                        
                        Text(location)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 40)
    }
}

// MARK: - 빈 이벤트 뷰
struct EmptyEventView: View {
    var body: some View {
        VStack(alignment: .center) {
            
            Spacer()
            
            Text("There are no events registered for today.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(height: 120)
    }
}

// MARK: - 권한 없음 뷰
struct NoAccessView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text("캘린더 접근 권한 필요")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            
            Text("일정을 표시하려면 권한을 허용해주세요")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("권한 요청") {
                Task {
                    await calendarManager.requestCalendarAccess()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}


#Preview {
    CalendarView()
        .environmentObject(CalendarManager.shared)
        .frame(width: 570, height: 185)
}


#Preview {
    EmptyView()
        .environmentObject(CalendarManager.shared)
        .frame(width: 570, height: 185)
}


#Preview {
    NoAccessView()
        .environmentObject(CalendarManager.shared)
        .frame(width: 570, height: 185)
}

#Preview {
    HomeView(currentTab: .constant(.studio))
        .environmentObject(CalendarManager.shared)
        .environmentObject(MusicManager.shared)
        .frame(width: onNotchSize.width, height: onNotchSize.height)
        .background(.black)
}
