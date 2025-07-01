//
//  TrayFile.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/28/25.
//

import SwiftUI


//tray에 담은 파일을 정의
// 파일의 이름 + 아이콘 + 파일확장자만 보이게 함
struct TrayFile: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileExtension: String
    let thumbnailData: Data?  // 파일 저장하면 미리보기
}
