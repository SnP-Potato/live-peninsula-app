//
//  CalendarView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/29/25.
//

import SwiftUI
import EventKit


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
            .frame(width: 140)
        }
        .frame(width: 190, height: 130)
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
            // 항상 오늘 날짜로 초기화
            let today = Calendar.current.startOfDay(for: Date())
            selectedDate = today
            calendarManager.updateFocusDate(today)
            
            // 권한 체크
            Task {
                if calendarManager.accessStatus == .notDetermined {
                    await calendarManager.requestCalendarAccess()
                } else if calendarManager.accessStatus == .fullAccess {
                    calendarManager.loadTodayEvent()
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
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")  // 영어 AM/PM 강제
        formatter.amSymbol = "AM"  // AM 심볼 명시적 설정
        formatter.pmSymbol = "PM"  // PM 심볼 명시적 설정
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
                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
//                        .opacity(0.5)
                        .frame(width: 9, height: 9)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold)) //
                                .foregroundColor(.white.opacity(0.5))
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
                            .foregroundColor(.white)
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


// MARK: Preview 파트
#Preview {
    ScrollView(.vertical, showsIndicators: false) {
        CalendarView()
            .environmentObject(CalendarManager.shared)
            .frame(width: 570, height: 185)
        
        NoAccessView()
            .environmentObject(CalendarManager.shared)
            .frame(width: 570, height: 185)
        
        
        HomeView(currentTab: .constant(.studio))
            .environmentObject(CalendarManager.shared)
            .environmentObject(MusicManager.shared)
            .frame(width: onNotchSize.width, height: onNotchSize.height)
            .clipShape(NotchShape(cornerRadius: 100))
            .background(.black)
    }
    
}
