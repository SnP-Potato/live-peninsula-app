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
            
            //음악 영역
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
                    .frame(width: 120)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 30, height: 30)
                            .offset(x: 50, y: 40)
                    }
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 17) {
                        Image(systemName: "arrowtriangle.backward.fill")
                        
                        Image(systemName: "pause.fill")
                        
                        Image(systemName: "arrowtriangle.forward.fill")
                        
                    }
                    .frame(width: 120)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding(.bottom, 8)
                }
            }
            
            
            //메모장
            Spacer()
            
            //타이머, 갤린더
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#Preview {
    HomeView(currentTab: .constant(.studio))
        .frame(width: 540, height: 175)
}
