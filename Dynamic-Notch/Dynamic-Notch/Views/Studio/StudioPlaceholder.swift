//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    @State private var musicCardclick: Bool = false
    @EnvironmentObject var calendarManager: CalendarManager
    @ObservedObject var musicManager = MusicManager.shared
    @EnvironmentObject var weatherManager: WeatherManager
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: 음악 제어 (스마트 진행바 적용)
            VStack(spacing: 6) {
                Button(action: {
                    musicCardclick.toggle()
                }, label: {
                    MusicCardView(musicCardclick: $musicCardclick)
                })
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 120, height: 110)
            .padding(.bottom, 12)
            
            Spacer()
                .frame(width: 18)
            
            // MARK: 캘린더
            VStack(alignment: .leading, spacing: 0) {
                CalendarView()
            }
            .frame(width: 170, height: 130, alignment: .leading)
            
            Spacer()
                .frame(width: 18)
            
            // MARK: 액션버튼
            Rectangle()
                .fill(.white.opacity(0.1))
                .cornerRadius(12)
                .frame(width: 150, height: 110)
                .padding(.bottom, 12)
                .opacity(0.5)
                .overlay{
                   
//                    ShortcutWheelPicker()
                    WeatherView()
                }
                .padding(.bottom, 12)
            
//            Spacer()
//                .frame(width: 18)
        }
        .frame(width: 500, height: 130)
        .padding(.vertical, 8)
    }
}

struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        StudioPlaceholder()
            .environmentObject(CalendarManager.shared)
            .environmentObject(MusicManager.shared)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 500, height: 130)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
