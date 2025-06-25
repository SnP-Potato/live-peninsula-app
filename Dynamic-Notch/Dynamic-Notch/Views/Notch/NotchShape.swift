//
//  NotchShape.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import SwiftUI

struct NotchShape: Shape {
    var cornerRadius: CGFloat
    
    var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 노치 모양 정의
        // 노치 상태에 따라 곡선 크기 조정
        let isOpen = cornerRadius > 20  // 열렸을 때 판단 기준
        
        let topCorner: CGFloat = isOpen ? 15 : 5      // 열렸을 때 더 큰 곡선
        let bottomCorner: CGFloat = isOpen ? 25 : 10  // 열렸을 때 더 큰 곡선
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) //(0,0)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) //(200, 0)
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX - topCorner, y: rect.minY + topCorner), control: CGPoint(x: rect.maxX - topCorner, y: rect.minY)) //(195, 5) & 제어점 (195,0)
        //
        path.addLine(to: CGPoint(x: rect.maxX - topCorner, y: rect.maxY - bottomCorner)) //(195, 22)
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX - topCorner - bottomCorner , y: rect.maxY), control: CGPoint(x: rect.maxX - topCorner, y: rect.maxY)) // (185, 32)
        
        
        //하단 평행선
        path.addLine(to: CGPoint(x: rect.minX + topCorner + bottomCorner, y: rect.maxY)) //(15, 32)
        
        path.addQuadCurve(to: CGPoint(x: rect.minX + topCorner, y: rect.maxY - bottomCorner), control: CGPoint(x: rect.minX + topCorner, y: rect.maxY)) //(5, 22)
        
        path.addLine(to: CGPoint(x: rect.minX + topCorner, y: rect.minY + topCorner))
        
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: rect.minX + topCorner, y: rect.minY))
        
        // 닫기
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    NotchShape(cornerRadius: 20)
        .frame(width: 200, height: 32)
        .padding(.all, 100)
}



