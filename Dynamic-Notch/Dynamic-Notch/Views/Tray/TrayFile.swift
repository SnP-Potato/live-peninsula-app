//
//  TrayFile.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/28/25.
//

import SwiftUI

struct TrayFile: Identifiable {
    let id: UUID
    let fileName: String
    let size: Int64
    let dateAdded: Date
    let fileType: String
    
}
