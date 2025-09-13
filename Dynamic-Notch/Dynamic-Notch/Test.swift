//
//  Test.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 9/12/25.
//

import SwiftUI

extension Bundle {
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
}

struct TestView: View {
    var body: some View {
        Text("\(Bundle.main.buildNumber)")
            .padding()
            .frame(width: 300, height: 200)
    }
}

#Preview {
    TestView()
}
