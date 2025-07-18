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
            RoundedRectangle(cornerRadius: 22)
                .fill(.black.opacity(0.2))
            
            HStack {
                //왼쪽
                VStack(spacing: 20) {
                    Image("Group 50")
                    
                    Text("Timer")
                        .font(.system(size: 26, weight: .bold))
                }
                
                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.2))
                        .frame(width: 230, height: 60)
                        .overlay {
                            HStack {
                                Text("00 : 00 : 00")
                                    .font(.system(size: 30, weight: .bold))
                            }
                        }
                    
                    HStack {
                        
                        Button(action: {
                            
                        }, label:  {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.2))
                                .frame(width: 70, height: 40)
                                .overlay {
                                    Text("Restart")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                            .frame(width: 70)
                        
                        Button(action: {
                            
                        }, label:  {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.2))
                                .frame(width: 70, height: 40)
                                .overlay {
                                    Text("Start")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
            }
        }
    }
}

#Preview {
    TimerView()
        .frame(width: 480, height:  500)
        
}
