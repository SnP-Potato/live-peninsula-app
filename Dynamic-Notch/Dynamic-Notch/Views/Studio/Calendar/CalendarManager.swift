//
//  CalendarManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/29/25.
//

import Foundation
import EventKit


class CalendarManager: NSObject, ObservableObject {
    static let shared = CalendarManager()
    
    //MARK: 이 EKEventStore로 캘린더, 미리암림 테이더 접근함
    private let eventStore = EKEventStore()
    
    //MARK: UI변수들
    @Published var focusDate: Date = Date()
    @Published var focusDayEvent: [EKEvent] = []
    
    //MARK: 캘린더 관리 변수 (캘린더 카테고리랑 선택사항)
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIDs: Set<String> = []
    
    //MARK: 권한변수들
    @Published var accessStatus: EKAuthorizationStatus = .notDetermined
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    // 1, 5, 31
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: focusDate)
    }
    
    // june -> jun
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: focusDate)
    }
    
    // Monday -> Mon 이렇게
    var formattedWeekend: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: focusDate)
    }
    
    private override init() {
        super.init()
        
        checkAccessStatus()
    }
    
    
    //MARK: 권한 관리 함수
    private func checkAccessStatus() {
        accessStatus = EKEventStore.authorizationStatus(for: .event) //지금 캘린더에 접근권한이 있는지 권한상태를 확인해주는 메소드ㅡ
        print("\(accessStatus)")
    }
    
    func requestCalendarAccess() async {
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted, error == nil {
                    print("정상적으로 처리함")
                    
                    //에러 없으면 상태 변경
                    self?.accessStatus = .fullAccess
                    self?.loadAvailableCalendars()
                    self?.loadTodayEvent()
                } else {
                    self?.accessStatus = .denied
                    self?.isError = true
                }
            }
        }
    }
    
    
    //MARK: 캘린더 데이터 로드이하는 함수
    func loadAvailableCalendars() {
        availableCalendars = eventStore.calendars(for: .event)
        
        selectedCalendarIDs = Set(availableCalendars.map { $0.calendarIdentifier })
        
        print("지금 캘린더 개수: \(availableCalendars.count)")
        
        for calendar in availableCalendars {
            print(" \(calendar.title): \(calendar.calendarIdentifier)")
        }
    }
    
    func loadTodayEvent() {
        loadEventForDate(focusDate)
    }
    
    func loadEventForDate(_ date: Date)  {
        guard accessStatus == .fullAccess else {
            print("권한이 없다")
            return
        }
        
        let startDay = Calendar.current.startOfDay(for: date)
        let endDay = Calendar.current.date(byAdding: .day, value: 1, to: startDay) ?? date
        
        //선택된 캘ㄹㄴ더 목록만 보여주기
        let selectedCalendars = availableCalendars.filter {
            selectedCalendarIDs.contains($0.calendarIdentifier)
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDay,    // 언제부터 찾을 건지
            end: endDay,           // 언제까지 찾을 건지
            calendars: selectedCalendars.isEmpty ? nil : selectedCalendars          // 어느 캘린더에서 찾을 건지
        )
        
        let event = eventStore.events(matching: predicate)
        focusDayEvent = event/*.sorted{ $0.startDate < $1.startDate}*/
        
        print("오늘 \(date.formatted(.dateTime.month().day()))의 이벤트 \(focusDayEvent.count)개:")
            for events in focusDayEvent {
                print("  - \(events.title ?? "제목없음"): \(events.startDate.formatted(.dateTime.hour().minute()))")
            }
    }
    
    //MARK: 날짜 관리
    func updateFocusDate(_ newDate: Date) {
        focusDate = newDate
        loadEventForDate(focusDate)
    }
    
    
    //MARK: 선책 관리
    func toggleCalendarSelection(_ calendar: EKCalendar) {
        if selectedCalendarIDs.contains(calendar.calendarIdentifier) {
                // 현재 선택됨 → 선택 해제
                selectedCalendarIDs.remove(calendar.calendarIdentifier)
                print("캘린더 해제: \(calendar.title)")
            } else {
                // 현재 해제됨 → 선택
                selectedCalendarIDs.insert(calendar.calendarIdentifier)
                print("캘린더 선택: \(calendar.title)")
            }
            
            // 선택 변경 후 현재 날짜의 이벤트 다시 로드
            loadEventForDate(focusDate)
            
            print("현재 선택된 캘린더: \(selectedCalendarIDs.count)개")
    }
}
