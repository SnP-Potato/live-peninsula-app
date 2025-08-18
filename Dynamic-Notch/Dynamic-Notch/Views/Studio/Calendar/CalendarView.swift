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

// MARK: - 스와이프 가능한 날짜 선택기
struct SwipeableDateSelector: View {
    @Binding var currentDate: Date
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var hapticFeedback = false
    
    private let config = DatePickerConfiguration()
    
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
            
            // 스와이프 가능한 날짜/요일 영역
            ZStack {
                GeometryReader { geometry in
                    ZStack {
                        // 이전 날짜 (왼쪽)
                        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                            DateDisplayCard(date: previousDate)
                                .offset(x: -geometry.size.width + dragOffset)
                                .opacity(dragOffset > 20 ? min(dragOffset / 100, 1.0) : 0)
                        }
                        
                        // 현재 날짜 (중앙)
                        DateDisplayCard(date: currentDate)
                            .offset(x: dragOffset)
                            .scaleEffect(isAnimating ? 0.95 : 1.0)
                        
                        // 다음 날짜 (오른쪽)
                        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                            DateDisplayCard(date: nextDate)
                                .offset(x: geometry.size.width + dragOffset)
                                .opacity(dragOffset < -20 ? min(abs(dragOffset) / 100, 1.0) : 0)
                        }
                    }
                    .clipped()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let maxDrag: CGFloat = 54
                            dragOffset = max(-maxDrag, min(maxDrag, value.translation.width))
                        }
                        .onEnded { value in
                            handleSwipeEnd(translation: value.translation.width)
                        }
                )
            }
            .frame(width: 90, height: 60)
            
            Spacer()
                .frame(height: 10)
        }
        .frame(width: 60, height: 130)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticFeedback)
        .animation(.spring(response: config.animationDuration, dampingFraction: 0.8), value: dragOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
    }
    
    // MARK: - 스와이프 처리
    private func handleSwipeEnd(translation: CGFloat) {
        withAnimation(.spring(response: config.animationDuration, dampingFraction: 0.8)) {
            if translation > config.swipeThreshold {
                moveToPreviousDay()
            } else if translation < -config.swipeThreshold {
                moveToNextDay()
            }
            
            dragOffset = 0
        }
    }
    
    private func moveToPreviousDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let minDate = calendar.date(byAdding: .day, value: -config.pastDays, to: today)!
        
        if let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate),
           previousDate >= minDate {
            withAnimation(.spring(response: config.animationDuration, dampingFraction: 0.8)) {
                currentDate = previousDate
                isAnimating = true
            }
            hapticFeedback.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = false
            }
        }
    }
    
    private func moveToNextDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let maxDate = calendar.date(byAdding: .day, value: config.futureDays, to: today)!
        
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate),
           nextDate <= maxDate {
            withAnimation(.spring(response: config.animationDuration, dampingFraction: 0.8)) {
                currentDate = nextDate
                isAnimating = true
            }
            hapticFeedback.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = false
            }
        }
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
                .frame(width: 60, height: 130)
                .environmentObject(calendarManager) // CalendarManager 전달
            
            // 오른쪽: 해당 요일 이벤트
            ScrollView(.vertical, showsIndicators: false) {
                if calendarManager.accessStatus != .fullAccess {
                    NoAccessView()
                        .frame(maxWidth: .infinity)
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
            .frame(width: 90)
        }
        .frame(width: 170, height: 100)
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
                        .strokeBorder(eventColor, lineWidth: 1)
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle()
                                .strokeBorder(eventColor, lineWidth: 3)
                                .frame(width: 50, height: 5)
                        }
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 2 } // 약간 조정
                } else {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(eventColor, lineWidth: 1)
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
                Text(event.title ?? "제목 없음")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
