//
//  HomeView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/21/25.
//

import SwiftUI

struct HomeView: View {
    // 6/28 @State에서 @Binding로 변경 [ContentView에서 제이하기 위해]
    @Binding var currentTab: NotchMainFeaturesView
    @Namespace private var tabAnimation
    
    // 반복할 탭들 배열
    private let tabs: [NotchMainFeaturesView] = [.studio, .tray]
    
    var body: some View {
        VStack {
            
            //주요 화면 탭 버튼
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                            currentTab = tab
                        }
                    }, label: {
                        HStack(spacing: 12) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: .medium))
                            
                            if currentTab == tab {
                                Text(tab.title)
                                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                    })
                    .foregroundColor(currentTab == tab ? .white : .gray)
                    .padding(.horizontal, currentTab == tab ? 12 : 8)
                    .padding(.vertical, 6)
                    .background {
                        if currentTab == tab {
                            Capsule()
                                .fill(.black.opacity(0.2))
                                .overlay {
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                                }
                                .matchedGeometryEffect(id: "selectedTab", in: tabAnimation)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                
                Spacer()
            }
            .frame(width: 500, height: 30)
            .padding(.leading, 8)
            
            VStack {
                //각 탭 버튼에 맞는 view출력
                switch currentTab {
                case .studio:
                    StudioPlaceholder()
                case .tray:
                    TrayPlaceholder()
                }
            }
            .frame(width: 500, height: 100)
            
            //총합 500, 130
        }
        .frame(width: 540, height: 175)
    }
}

#Preview {
    HomeView(currentTab: .constant(.studio))
        .frame(width: onNotchSize.width, height: onNotchSize.height)
        .background(.black)
}

