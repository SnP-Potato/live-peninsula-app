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

//각 이벤트 상세정도 추출
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
        HStack(alignment: .center, spacing: 10) {
            
            //캘린더 목록 색 추출
            VStack(spacing: 0) {
                
                if isEventFinished {
                    Circle()
                        .strokeBorder(eventColor, lineWidth: 1)
                        .frame(width: 10, height: 10)
                        .overlay {
                            Circle()
                                .strokeBorder(eventColor, lineWidth: 3)
                                .frame(width: 50, height: 5)
                        }
                } else {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(eventColor, lineWidth: 1)
                        .frame(width: 10, height: 10)
                }
                
                if !lastEvent {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 20)
                }
            }
            .frame(width: 12, alignment: .center)
            
            //이벤트 제목, 기간, 위치
            VStack(alignment: .leading, spacing: 12) {
                // 이벤트 제목
                Text(event.title ?? "제목 없음")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 시간 표시
                HStack {
                    if isAllDay {
                        Text("All Day")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(eventColor)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(timeFormatter.string(from: event.startDate))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text(timeFormatter.string(from: event.endDate))
                                .font(.system(size: 11))
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

#Preview {
    EmptyEventView()
        .environmentObject(CalendarManager.shared)
        .frame(width:570, height: 185)
}


#Preview {
    NoAccessView()
        .environmentObject(CalendarManager.shared)
        .frame(width:570, height: 185)
}
