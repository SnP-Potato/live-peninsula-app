//
//  HomeView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/21/25.
//

import SwiftUI

struct HomeView: View {
    @State private var currentTab: NotchMainFeaturesView = .tray
    @Namespace private var tabAnimation
    
    // 반복할 탭들 배열
    private let tabs: [NotchMainFeaturesView] = [.studio, .tray]
    
    var body: some View {
        VStack {
            
            //주요 화면 탭 버튼
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            currentTab = tab
                        }
                    }, label: {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14, weight: .bold))
                            
                            if currentTab == tab {
                                Text(tab.title)
                                    .font(.system(size: 13, weight: .bold))
                            }
                        }
                    })
                    .foregroundColor(currentTab == tab ? .white : .gray)
                    .padding(.horizontal, currentTab == tab ? 12 : 8)
                    .padding(.vertical, 6)
                    .background {
                        if currentTab == tab {
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .overlay {
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                                }
                                .matchedGeometryEffect(id: "selectedTab", in: tabAnimation)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.bottom, 32)
            .frame(height: 32)
            //각 탭 버튼에 맞는 view출력
            switch currentTab {
            case .studio:
                StudioPlaceholder()
            case .tray:
                TrayPlaceholder()
            }
        }
    }
}

#Preview {
    HomeView()
        .frame(width: 540, height: 175)
        .background(.black)
}

