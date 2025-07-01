//
//  TrayManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/28/25.
//

// DynamicNotch에 TrayView에 저장소 구현
// 파일 등 드래그시 복사해서 저장
import SwiftUI
import Foundation

class TrayManager: ObservableObject {
   
    static let fm = TrayManager()
    
    @Published var files: [TrayFile] = []
    
//    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    
}
