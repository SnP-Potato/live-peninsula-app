//
//  HomeView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/21/25.
//

import SwiftUI

struct HomeView: View {
    @State private var currentTab: NotchMainFeaturesView = .studio
    @Namespace private var tabAnimation
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 버튼 영역 - 노치와 같은 위치로 상단에 배치
            HStack(spacing: 8) {
                // Studio 탭
                TabButton(
                    tab: .studio,
                    isSelected: currentTab == .studio,
                    namespace: tabAnimation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentTab = .studio
                    }
                }
                
                // Tray 탭
                TabButton(
                    tab: .tray,
                    isSelected: currentTab == .tray,
                    namespace: tabAnimation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentTab = .tray
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .frame(height: 32)  // 노치 높이와 맞춤
            
            // 선택된 탭의 콘텐츠
            ZStack {
                switch currentTab {
                case .studio:
                    StudioPlaceholder()
                        .id("studio")
                    
                case .tray:
                    TrayPlaceholder()
                        .id("tray")
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - 탭 버튼
struct TabButton: View {
    let tab: NotchMainFeaturesView
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                
                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .medium))
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, isSelected ? 12 : 8)  // 패딩 줄임
            .padding(.vertical, 6)  // 세로 패딩도 줄임
            .background {
                if isSelected {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .overlay {
                            Capsule()
                                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                        }
                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                } else if isHovered {
                    Capsule()
                        .fill(.white.opacity(0.1))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering && !isSelected
            }
        }
    }
}

// MARK: - Studio 플레이스홀더
struct StudioPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "widget.small")
                .font(.title)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Studio")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("음악, 미디어 컨트롤")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - Tray 플레이스홀더
struct TrayPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.title)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tray")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("파일 드롭 영역")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    HomeView()
        .frame(width: 540, height: 175)
        .background(.black)
}
