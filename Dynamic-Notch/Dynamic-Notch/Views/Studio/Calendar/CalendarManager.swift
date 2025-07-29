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
    private let enventStore = EKEventStore()
    
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
    
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: focusDate)
    }
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: focusDate)
    }
    
    var formattedWeekend: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: focusDate)
    }
    
    private override init() {
        super.init()
        
        checkAccessStatus()
    }
    
    private func checkAccessStatus() {
        accessStatus = EKEventStore.authorizationStatus(for: .event)
        print("\(accessStatus)")
    }
}
