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
                .frame(width: 25)
            
            // MARK: 캘린더
            VStack(alignment: .center, spacing: 0) {
                CalendarView()
            }
            .frame(width: 170, height: 130, alignment: .leading)
            
            Spacer()
                .frame(width: 18)
            
            // MARK: 액션버튼
            if #available(macOS 15.0, *) {
                Image(systemName: "faceid")
                        .font(.system(size: 80)) // ✅ 크기를 font로 지정
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 5.0)).speed(2.0))
                        .foregroundColor(.gray)
                        .frame(width: 120, height: 110)
            } else {
                Image(systemName: "faceid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 110)
                    .clipped()
            }
            
//            SystemHUDOverlayView()
//                .frame(width: 140, height: 110)
            
            Spacer()
                .frame(width: 18)
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




