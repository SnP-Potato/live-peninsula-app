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
            
            // 월, 요일 UI
            HStack {
                HStack {
                    VStack(spacing: 20) {
                        
                        Text("\(calendarManager.formattedMonth.uppercased())")
                            .font(.system(size: 26, weight: .black))
                        
                        VStack(spacing: 4) {
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
                    if calendarManager.accessStatus != .fullAccess {
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
                    } else if calendarManager.focusDayEvent.isEmpty {
                        VStack(alignment: .center) {
                            Text("There are no events registered for today.")
                                
                        }
                        
                    } else {
                        LazyVStack {
                            ForEach(sortedEvents, id: \.calendarItemIdentifier) { event in
                                EventRowView(event: event)
                            }
                        }
                        
                        
                    }
                }
            }
        }
        .frame(width: 200, height: 120)
        
        
    }
    private var sortedEvents: [EKEvent] {
        calendarManager.focusDayEvent.sorted { $0.startDate < $1.startDate }
    }
}


struct EventRowView: View {
    let event: EKEvent
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 캘린더 색상 인디케이터
                Circle()
                    .fill(eventColor)
                    .frame(width: 8, height: 8)
                
                // 이벤트 제목
                Text(event.title ?? "제목 없음")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                // 시간 표시
                if isAllDay {
                    Text("종일")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                } else {
                    Text(timeFormatter.string(from: event.startDate))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            // 위치 정보 (있을 경우)
            if let location = event.location, !location.isEmpty {
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                    
                    Text(location)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .padding(.leading, 16)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
                .strokeBorder(eventColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarManager.shared)
        .frame(width:570, height: 185)
        
}


