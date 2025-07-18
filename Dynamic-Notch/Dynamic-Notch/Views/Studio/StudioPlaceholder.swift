//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    
    @State private var isTap: Bool = false
    @State private var istimer: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            Spacer()
                .frame(width: 24)
            
            // 음악 영역
            HStack(spacing: 12) {
                // 음악 이미지
                Image("musicImage 1")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .scaledToFill()
                    .cornerRadius(12)
                    .overlay {
                        Image("musicApp")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .scaledToFill()
                            .cornerRadius(6)
                            .offset(x: 34, y: 34)
                    }
                
                // 음악 정보 및 컨트롤
                VStack(alignment: .center, spacing: 12) {
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Heat Waves")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("Grass Animals")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color("artist"))
                            .lineLimit(1)
                    }
                    .frame(width: 140)
                    
                    
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 140, height: 3)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 140 * 0.6) // 60%
                        }
                        .cornerRadius(1.5)
                    
                    // 컨트롤 버튼
                    HStack(spacing: 18) {
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 140)
                }
                .frame(width: 140)
            }
            .frame(width: 242)
            
            
            Spacer()
            
           
            VStack(alignment: .center, spacing: 10) {
                // 메모 영역
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 180, height: 42)
                    .foregroundColor(Color("memoColor"))
                    .overlay {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Text("Start Writing...")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Spacer()
                            
                            Text("31")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                    }
                
                // 집중모드 & 타이머 & 화면녹화 기능들
                HStack(spacing: 12) {
                    // 집중모드
                    Button(action: {
                        isTap.toggle()
                    }) {
                        Circle()
                            .fill(isTap ? Color.blue.opacity(0.2) : Color("3buttonColor"))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "moon.fill")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 12))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    //  타이머
                    Button(action: {
                        istimer.toggle()
                    }) {
                        Circle()
                            .fill(Color("3buttonColor"))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if istimer {
                                    TimerView()
                                        .frame(width: 24, height: 24)
                                } else {
                                    Image(systemName: "timer")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 12))
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 화면 녹화
                    Button(action: {
                        //
                    }) {
                        Circle()
                            .fill(Color("3buttonColor"))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 12))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 180)
            
            
            Spacer()
                .frame(width: 24)
        }
        .frame(height: 90)
        .padding(.vertical, 8)
    }
}

struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentTab: .constant(.studio))
            .environmentObject(NotchViewModel())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: onNotchSize.width, height: onNotchSize.height)
            .background(Color.black)
            .clipShape(NotchShape(cornerRadius: 20))
    }
}
