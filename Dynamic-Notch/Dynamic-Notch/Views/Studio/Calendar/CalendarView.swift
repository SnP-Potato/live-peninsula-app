//
//  CalendarView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/29/25.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var selectedDate = Date()
    var body: some View {
        VStack {
            HStack {
                HStack {
                    VStack(spacing: 20) {
                        
                        // 월, 요일 UI
                        Text("\(calendarManager.formattedMonth.uppercased())")
                            .font(.system(size: 26, weight: .black))
                        
                        HStack(spacing: 4) {
                            Text("\(calendarManager.formattedWeekend)")
                            
                            Text("\(calendarManager.formattedDay)")
                        }
                        .font(.system(size: 20, weight: .heavy))
                    }
                    
                    
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 1)
                }
                
                //해당 요일 이벤트
                ScrollView(.vertical, showsIndicators: false) {
                    if calendarManager.accessStatus != .fullAccess { // 권한이 없을때
                        NoAccessView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else if calendarManager.focusDayEvent.isEmpty { // 이벤트가 없을때
                        EmptyEventView()
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(sortedEvents.enumerated()), id: \.element.calendarItemIdentifier) { index, event in
                                EventRowView(
                                    event: event,
                                    lastEvent: index == sortedEvents.count - 1  // 👈 이렇게!
                                )
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 200, height: 120)
        .onAppear {
            // 뷰가 나타날 때 권한 체크하고 이벤트 로드
            Task {
                if calendarManager.accessStatus == .notDetermined {
                    await calendarManager.requestCalendarAccess()
                } else if calendarManager.accessStatus == .fullAccess {
                    calendarManager.loadTodayEvent()
                }
            }
        }
    }
    private var sortedEvents: [EKEvent] {
            calendarManager.focusDayEvent.sorted { $0.startDate < $1.startDate }
    }
}



//각 이벤트 상세정보 추출
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
        HStack(alignment: .top, spacing: 10) {
            
            //캘린더 목록 색 추출
            VStack {
                if isEventFinished {
                    Circle()
                        .strokeBorder(eventColor, lineWidth: 1)
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle()
                                .strokeBorder(eventColor, lineWidth: 3)
                                .frame(width: 50, height: 5)
                        }
                } else {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(eventColor, lineWidth: 1)
                        .frame(width: 8, height: 8)
                }
                Spacer()
                    
                
                if !lastEvent {
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 1)
                        .frame(minHeight: 30)
                }
            }
            .frame(width: 12, alignment: .top)
            
            //이벤트 제목, 기간, 위치
            VStack(alignment: .leading, spacing: 4) {
                // 이벤트 제목
                Text(event.title ?? "제목 없음")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
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
            .frame(height: 34)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct EmptyEventView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("There are no events registered for today.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

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
        .frame(width:570, height: 185)
}

//#Preview {
//    EmptyEventView()
//        .environmentObject(CalendarManager.shared)
//        .frame(width:570, height: 185)
//}





//import SwiftUI
//import EventKit
//
//// MARK: - Calendar Configuration
//struct CalendarConfig: Equatable {
//    var past: Int = 3
//    var future: Int = 7
//    var steps: Int = 1
//    var spacing: CGFloat = 2 // 날짜 간격 증가
//    var offset: Int = 1      // 오프셋 줄임
//}
//
//struct CalendarView: View {
//    @EnvironmentObject var calendarManager: CalendarManager
//    @State private var selectedDate = Date()
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 10) { // alignment를 .top으로 변경
//            // 왼쪽: 월 표시 + 날짜 선택기
//            VStack(alignment: .center, spacing: 2) { // spacing을 2로 줄임
//                // 월 표시
//                Text(calendarManager.formattedMonth.uppercased())
//                    .font(.system(size: 18, weight: .black))
//                    .foregroundStyle(.white)
//                    .frame(height: 22) // 높이 조정
//                
//                // 세로 날짜 선택기
//                ZStack {
//                    VerticalWheelDatePicker(
//                        selectedDate: $selectedDate,
//                        config: CalendarConfig()
//                    )
//                    
//                    // 그라데이션 마스크
//                    VStack(spacing: 0) {
//                        LinearGradient(
//                            colors: [.black, .clear],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                        .frame(height: 10)
//                        
//                        Spacer()
//                        
//                        LinearGradient(
//                            colors: [.clear, .black],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                        .frame(height: 10)
//                    }
//                    .allowsHitTesting(false)
//                }
//                .frame(height: 76) // 높이 더 조정
//                
//                Spacer(minLength: 0) // 남은 공간 채우기
//            }
//            .frame(width: 70)
//            
//            // 구분선
//            Rectangle()
//                .fill(.white.opacity(0.1))
//                .frame(width: 1)
//                .frame(height: 100) // 명시적 높이 설정
//            
//            // 오른쪽: 이벤트 리스트
//            VStack(alignment: .leading, spacing: 0) {
//                ScrollView(.vertical, showsIndicators: false) {
//                    if calendarManager.accessStatus != .fullAccess {
//                        NoAccessView()
//                    } else if calendarManager.focusDayEvent.isEmpty {
//                        EmptyEventView()
//                    } else {
//                        LazyVStack(spacing: 6) {
//                            ForEach(Array(sortedEvents.enumerated()), id: \.element.calendarItemIdentifier) { index, event in
//                                CompactEventRowView(
//                                    event: event,
//                                    isLast: index == sortedEvents.count - 1
//                                )
//                            }
//                        }
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 4)
//                    }
//                }
//                .frame(height: 100) // 명시적 높이 설정
//                
//                Spacer(minLength: 0)
//            }
//            .frame(maxWidth: .infinity, alignment: .topLeading) // topLeading 정렬
//        }
//        .frame(width: 200, height: 120, alignment: .top) // 전체를 top으로 정렬
//        .onChange(of: selectedDate) { _, newDate in
//            calendarManager.updateFocusDate(newDate)
//        }
//        .onAppear {
//            Task {
//                if calendarManager.accessStatus == .notDetermined {
//                    await calendarManager.requestCalendarAccess()
//                } else if calendarManager.accessStatus == .fullAccess {
//                    calendarManager.loadTodayEvent()
//                }
//            }
//            selectedDate = calendarManager.focusDate
//        }
//    }
//    
//    private var sortedEvents: [EKEvent] {
//        calendarManager.focusDayEvent.sorted { $0.startDate < $1.startDate }
//    }
//}
//
//// MARK: - Updated VerticalWheelDatePicker with Better Positioning
//struct VerticalWheelDatePicker: View {
//    @Binding var selectedDate: Date
//    @State private var scrollPosition: Int?
//    @State private var haptics: Bool = false
//    @State private var byClick: Bool = false
//    let config: CalendarConfig
//    
//    var body: some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            LazyVStack(spacing: config.spacing) {
//                let totalSteps = config.steps * (config.past + config.future)
//                let spacerNum = 1 // 스페이서 개수 줄임
//                
//                ForEach(0..<totalSteps + 2 * spacerNum + 1, id: \.self) { index in
//                    if index < spacerNum || index > totalSteps + spacerNum - 1 {
//                        // 매우 작은 스페이서
//                        Spacer()
//                            .frame(height: 2)
//                            .id(index)
//                    } else {
//                        let offset = -spacerNum - config.past
//                        let date = dateForIndex(index, offset: offset)
//                        let isSelected = isDateSelected(index, offset: offset)
//                        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
//                        
//                        dateButton(
//                            date: date,
//                            isSelected: isSelected,
//                            isToday: isToday,
//                            offset: offset
//                        ) {
//                            selectedDate = date
//                            byClick = true
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                scrollPosition = indexForDate(date, offset: offset) - spacerNum
//                            }
//                            haptics.toggle()
//                        }
//                        .id(indexForDate(date, offset: offset))
//                    }
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .frame(width: 60, height: 76)
//        .scrollIndicators(.never)
//        .scrollPosition(id: $scrollPosition, anchor: .top) // top으로 변경
//        .sensoryFeedback(.alignment, trigger: haptics)
//        .onChange(of: scrollPosition) { oldValue, newValue in
//            if !byClick {
//                handleScrollChange(newValue: newValue)
//            } else {
//                byClick = false
//            }
//        }
//        .onAppear {
//            scrollToToday()
//        }
//    }
//    
//    // 나머지 함수들은 이전과 동일...
//    private func dateButton(
//        date: Date,
//        isSelected: Bool,
//        isToday: Bool,
//        offset: Int,
//        onClick: @escaping () -> Void
//    ) -> some View {
//        Button(action: onClick) {
//            HStack(spacing: 4) {
//                Text(dayString(for: date))
//                    .font(.system(size: 9, weight: .medium))
//                    .foregroundStyle(
//                        isSelected ? .blue :
//                        isToday ? .white : .gray
//                    )
//                    .frame(width: 20, alignment: .leading)
//                
//                ZStack {
//                    Circle()
//                        .fill(
//                            isSelected ? .blue :
//                            isToday ? .white.opacity(0.2) : .clear
//                        )
//                        .frame(width: 22, height: 22)
//                    
//                    Text("\(dayNumber(for: date))")
//                        .font(.system(size: 11, weight: .semibold))
//                        .foregroundStyle(
//                            isSelected ? .white :
//                            isToday ? .white : .gray
//                        )
//                }
//            }
//            .frame(width: 60, height: 24) // 높이 줄임
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//    
//    private func handleScrollChange(newValue: Int?) {
//        let offset = -1 - config.past // 스페이서 개수에 맞춰 조정
//        let todayIndex = indexForDate(Date(), offset: offset)
//        guard let newIndex = newValue else { return }
//        let targetDateIndex = newIndex + 1
//        
//        switch targetDateIndex {
//        case todayIndex - config.past..<todayIndex + config.future:
//            selectedDate = dateForIndex(targetDateIndex, offset: offset)
//            haptics.toggle()
//        default:
//            return
//        }
//    }
//    
//    private func scrollToToday() {
//        let today = Date()
//        let todayIndex = indexForDate(today, offset: -1 - config.past)
//        byClick = true
//        scrollPosition = todayIndex - 1
//        selectedDate = today
//    }
//    
//    private func indexForDate(_ date: Date, offset: Int) -> Int {
//        let calendar = Calendar.current
//        let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: Date()) ?? Date())
//        let targetDate = calendar.startOfDay(for: date)
//        let daysDifference = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
//        return daysDifference
//    }
//    
//    private func dateForIndex(_ index: Int, offset: Int) -> Date {
//        let startDate = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
//        return Calendar.current.date(byAdding: .day, value: index, to: startDate) ?? Date()
//    }
//    
//    private func dayString(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "E"
//        return formatter.string(from: date)
//    }
//    
//    private func dayNumber(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d"
//        return formatter.string(from: date)
//    }
//    
//    private func isDateSelected(_ index: Int, offset: Int) -> Bool {
//        Calendar.current.isDate(dateForIndex(index, offset: offset), inSameDayAs: selectedDate)
//    }
//}
//// MARK: - Compact Event Row View (개선된 이벤트 표시)
//struct CompactEventRowView: View {
//    let event: EKEvent
//    let isLast: Bool
//    
//    private var timeFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter
//    }
//    
//    private var isAllDay: Bool {
//        let calendar = Calendar.current
//        let startComponents = calendar.dateComponents([.hour, .minute], from: event.startDate)
//        return startComponents.hour == 0 && startComponents.minute == 0
//    }
//    
//    private var eventColor: Color {
//        if let cgColor = event.calendar.cgColor {
//            return Color(cgColor)
//        }
//        return .blue
//    }
//    
//    private var isEventFinished: Bool {
//        Date() > event.endDate
//    }
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 10) {
//            
//            //캘린더 목록 색 추출
//            VStack(spacing: 0) {
//                
//                if isEventFinished {
//                    Circle()
//                        .strokeBorder(eventColor, lineWidth: 1)
//                        .frame(width: 10, height: 10)
//                        .overlay {
//                            Circle()
//                                .strokeBorder(eventColor, lineWidth: 3)
//                                .frame(width: 50, height: 5)
//                        }
//                } else {
//                    Circle()
//                        .fill(.clear)
//                        .strokeBorder(eventColor, lineWidth: 1)
//                        .frame(width: 10, height: 10)
//                }
//                
//                if !isLast {
//                    Rectangle()
//                        .fill(.gray.opacity(0.3))
//                        .frame(width: 2)
//                        .frame(minHeight: 20)
//                }
//            }
//            .frame(width: 12, alignment: .center)
//            
//            //이벤트 제목, 기간, 위치
//            VStack(alignment: .leading, spacing: 12) {
//                // 이벤트 제목
//                Text(event.title ?? "제목 없음")
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(.white)
//                    .lineLimit(2)
//                    .fixedSize(horizontal: false, vertical: true)
//                
//                // 시간 표시
//                HStack {
//                    if isAllDay {
//                        Text("All Day")
//                            .font(.system(size: 11, weight: .medium))
//                            .foregroundColor(eventColor)
//                    } else {
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text(timeFormatter.string(from: event.startDate))
//                                .font(.system(size: 11, weight: .medium))
//                                .foregroundColor(.gray)
//                            
//                            Text(timeFormatter.string(from: event.endDate))
//                                .font(.system(size: 11))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    
//                    Spacer()
//                }
//                
//                // 위치 정보 (있을 경우)
//                if let location = event.location, !location.isEmpty {
//                    HStack(spacing: 4) {
//                        Image(systemName: "arcade.stick")
//                            .font(.system(size: 10))
//                            .foregroundColor(eventColor)
//                        
//                        Text(location)
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray)
//                            .lineLimit(1)
//                        
//                        Spacer()
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(.horizontal, 8)
//        .padding(.vertical, 4)
//    }
//}
//
//// MARK: - Empty Event View (개선됨)
//struct EmptyEventView: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "calendar")
//                .font(.system(size: 20))
//                .foregroundColor(.gray.opacity(0.5))
//            
//            Text("No events")
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(.gray)
//            
//            Text("Enjoy your free time!")
//                .font(.system(size: 9))
//                .foregroundColor(.gray.opacity(0.7))
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 80)
//    }
//}
//
//// MARK: - No Access View (개선됨)
//struct NoAccessView: View {
//    @EnvironmentObject var calendarManager: CalendarManager
//    
//    var body: some View {
//        VStack(spacing: 6) {
//            Image(systemName: "calendar.badge.exclamationmark")
//                .font(.system(size: 18))
//                .foregroundColor(.orange)
//            
//            Text("Calendar Access Required")
//                .font(.system(size: 10, weight: .medium))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//            
//            Text("Please allow access to show your events")
//                .font(.system(size: 8))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//            
//            Button("Request Access") {
//                Task {
//                    await calendarManager.requestCalendarAccess()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .controlSize(.mini)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 80)
//        .padding(.horizontal, 8)
//    }
//}
//
//#Preview {
//    CalendarView()
//        .environmentObject(CalendarManager.shared)
//        .frame(width:570, height: 185)
//}
//
//
//#Preview {
//    EmptyEventView()
//        .environmentObject(CalendarManager.shared)
//        .frame(width:570, height: 185)
//}
