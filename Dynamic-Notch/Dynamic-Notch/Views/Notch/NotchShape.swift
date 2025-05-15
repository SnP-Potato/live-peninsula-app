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
            let topCornerRadius: CGFloat = min(cornerRadius, 10)
            
            // 상단 좌측 코너
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
                control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
            )
            
            // 좌측 수직선
            path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - cornerRadius))
            
            // 하단 좌측 코너
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + topCornerRadius + cornerRadius, y: rect.maxY),
                control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
            )
            
            // 하단 수평선
            path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - cornerRadius, y: rect.maxY))
            
            // 하단 우측 코너
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - cornerRadius),
                control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
            )
            
            // 우측 수직선
            path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))
            
            // 상단 우측 코너
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY),
                control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
            )
            
            // 닫기
            path.closeSubpath()
            
            return path
        }
    }
//    var topCorner: CGFloat = 5
//    var bottomCorner: CGFloat = 10
//    
//    func path(in rect: CGRect) -> Path {
//        Path { path in
//            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) //(0,0)
//            
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) //(200, 0)
//            
//            path.addQuadCurve(to: CGPoint(x: rect.maxX - topCorner, y: rect.minY + topCorner), control: CGPoint(x: rect.maxX - topCorner, y: rect.minY)) //(195, 5) & 제어점 (195,0)
//            //
//            path.addLine(to: CGPoint(x: rect.maxX - topCorner, y: rect.maxY - bottomCorner)) //(195, 22)
//            
//            path.addQuadCurve(to: CGPoint(x: rect.maxX - topCorner - bottomCorner , y: rect.maxY), control: CGPoint(x: rect.maxX - topCorner, y: rect.maxY)) // (185, 32)
//            
//            
//            //하단 평행선
//            path.addLine(to: CGPoint(x: rect.minX + topCorner + bottomCorner, y: rect.maxY)) //(15, 32)
//            
//            path.addQuadCurve(to: CGPoint(x: rect.minX + topCorner, y: rect.maxY - bottomCorner), control: CGPoint(x: rect.minX + topCorner, y: rect.maxY)) //(5, 22)
//            
//            path.addLine(to: CGPoint(x: rect.minX + topCorner, y: rect.minY + topCorner))
//            
//            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: rect.minX + topCorner, y: rect.minY))
//            
//        }
//    }



#Preview {
    NotchShape(cornerRadius: 20)
        .frame(width: 200, height: 32)
        .padding(.all, 100)
}
