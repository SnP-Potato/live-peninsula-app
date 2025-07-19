//
//  TimerView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/18/25.
//

import SwiftUI

struct TimerView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.1))
            
            HStack(spacing: 8) {
                VStack(spacing: 8) {
                    Image("Group 50")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 38, height: 38)
                    
                    Text("Timer")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(height: 80)
                
                // 오른쪽 - 시간과 버튼들
                VStack(spacing: 12) {
                    // 시간 표시
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.2))
                        .frame(width: 120, height: 34)
                        .overlay {
                            Text("00 : 00 : 00")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    
                    // 버튼들
                    HStack(spacing: 18) {
                        Button(action: {
                            
                        }) {
                            Circle()
                                .fill(.orange.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text("Restart")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            
                        }) {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 37, height: 37)
                                .overlay {
                                    Text("Start")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TimerView()
        .frame(width: 480, height:  500)
    
}
