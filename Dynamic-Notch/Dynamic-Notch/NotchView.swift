//
//  NotchView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 4/9/25.
//

import SwiftUI

struct NotchView: View {
    @StateObject var viewModel = NotchViewModel()
    
    var body: some View {
        ZStack {
            // 노치가 켜진 상태일 때 보여줄 콘텐츠
            if viewModel.notchStatus == .on {
                // 메인 콘텐츠 (예: 음악 플레이어, 캘린더 등)
                Text("Notch Content")
                    .transition(.opacity)
            } else {
                // 노치가 꺼진 상태일 때 보여줄 콘텐츠 (최소화된 정보)
                Text("•••")
                    .transition(.opacity)
            }
        }
        .frame(width: viewModel.notchSize.width, height: viewModel.notchSize.height)
        .background(
            RoundedRectangle(cornerRadius: viewModel.notchStatus == .on ? cornerRadiusSet.on : cornerRadiusSet.off)
                .fill(Color.black.opacity(0.8))
        )
        // 여기에 onHover가 필요하지만, AppKit/NSView 기반 구현이 필요할 수 있음
    }
}

#Preview {
    NotchView()
}
