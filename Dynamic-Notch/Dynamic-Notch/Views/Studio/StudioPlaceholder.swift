//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            
            HStack(spacing: 8) {
                //음악 영역
                HStack(spacing: 18) {
                    Image("musicImage 1")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .overlay {
                            Image("musicApp")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .scaledToFill()
                                .cornerRadius(8)
                                .offset(x: 50, y: 44)
                            
                        }
                    
                    VStack(alignment: .center, spacing: 12) {
                        
                        //텍스트 그룹
                        VStack(spacing: 2) {
                            Text("Heat Waves")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text("Grass Animals")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color("artist"))
                        }
                        
                        //음악 진행바
                        Rectangle()
                            .fill(.white.opacity(0.1))  // 배경 회색
                            .frame(height: 3)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(.white)  // 진행된 부분 흰색
                                    .frame(width: 120 * 0.6)  // 60% 진행된 상태
                            }
                            .frame(width: 120)  // 전체 너비
                            .cornerRadius(2)
                        
                        
                        //트랩 선택view
                        HStack(spacing: 14) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 18))
                            
                            Image(systemName: "pause.fill")
                                .font(.system(size: 20))
                            
                            Image(systemName: "forward.fill")
                                .font(.system(size: 18))
                            
                        }
                        .frame(width: 120)
                        .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                
                
                //기능들
                VStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("memoYellow"),
                                        Color("memoYellow2"),
                                        Color("memoYellow3")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 200, height: 45)
                            .offset(x: 0, y: -7)
//                            .overlay {
//                                Text("MEMO")
//                                    .font(.system(size: 5, weight: .black))
//                                    .foregroundColor(Color("memoText"))
//                                    .offset(x: -80, y:-27)
//                            }
                        
                        
                        Rectangle()
                            .frame(width: 201, height: 45)
                            .foregroundColor(Color("memoColor"))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 8,
                                    bottomTrailingRadius: 8,
                                    topTrailingRadius: 0
                                )
                            )
                        
                    }
//                    .padding(.top, 15)
//                    .frame(height: 60)
                    
                    
                    //집중모드, 타이머, 녹화 버튼
                    HStack(spacing: 10) {
                        // 다크모드 토글
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "moon.fill")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 14))
                            }
                        
                        Spacer()
                        
                        // 포모도로 타이머
                        Circle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "timer")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 14))
                            }
                        
                        Spacer()
                        
                        // 화면 녹화
                        Circle()
                            .fill(.red.opacity(0.2))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 14))
                            }
                    }
                    .frame(width: 180)
                }
//                .padding(.bottom, 10)
            }
        }
        .padding(.horizontal, 8)
    }
}

struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        StudioPlaceholder()
            .environmentObject(NotchViewModel())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: onNotchSize.width, height: onNotchSize.height)
            .background(Color.black)
            .clipShape(NotchShape(cornerRadius: 20))
    }
}
