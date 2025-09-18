//
//  charginLA.swift
//  Live Peninsula
//
//  Created by PeterPark on 9/16/25.
//

import SwiftUI

struct charginLA: View {
    @EnvironmentObject var vm: NotchViewModel
    @EnvironmentObject var chargeDetectManager: ChargeDetectManager
    
    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 동적 충전 상태 아이콘
            HStack(spacing: 4) {
                Image(systemName: chargeDetectManager.currentStatus.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(chargeDetectManager.currentStatus.iconColor)
                    .animation(.easeInOut(duration: 0.3), value: chargeDetectManager.currentStatus)
                
                // 충전 중일 때만 펄스 애니메이션 점 표시
                if chargeDetectManager.currentStatus == .charging {
                    Circle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 4, height: 4)
                        .scaleEffect(chargeDetectManager.isHUDActive ? 1.3 : 0.7)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: chargeDetectManager.isHUDActive)
                }
            }
            .frame(width: 40, height: 25)
            .padding(.leading, 6)
            .padding(.trailing, 6)
            
            // 중앙: 노치 기본 영역 (검정색)
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width - 25)
                .padding(.trailing, 5)
            
            // 오른쪽: 배터리 레벨과 상태 정보
            VStack(spacing: 1) {
                // 메인 정보 (배터리 퍼센트 또는 상태)
                if chargeDetectManager.currentStatus == .charging || chargeDetectManager.currentStatus == .fullyCharged {
                    Text("\(Int(chargeDetectManager.batteryLevel))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text(chargeDetectManager.currentStatus.displayText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                }
                
                // 서브 정보 (상태 텍스트)
                if chargeDetectManager.currentStatus == .charging || chargeDetectManager.currentStatus == .fullyCharged {
                    Text(chargeDetectManager.currentStatus.displayText)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(width: 70, alignment: .trailing)
            .padding(.trailing, 8)
            .animation(.easeInOut(duration: 0.2), value: chargeDetectManager.currentStatus)
        }
        // 탭해서 HUD 수동으로 숨김
        .onTapGesture {
            chargeDetectManager.hideHUD()
        }
        .frame(width:  230,height: 32)
    }
}

#Preview {
    charginLA()
        .environmentObject(NotchViewModel())
        .environmentObject(ChargeDetectManager.shared)
        .frame(width: 400, height: 50)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
}
