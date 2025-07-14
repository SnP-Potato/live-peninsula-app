//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    
    @State private var isTap: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            
            HStack(spacing: 8) {
                //음악 영역
                HStack(spacing: 15) {
                    Image("musicImage 1")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .overlay {
                            Image("musicApp")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .scaledToFill()
                                .cornerRadius(8)
                                .offset(x: 50, y: 44)
                            
                        }
                    
                    VStack(alignment: .center, spacing: 12) {
                        
                        //텍스트 그룹
                        VStack(spacing: 2) {
                            Text("Heat Waves")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text("Grass Animals")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color("artist"))
                        }
                        
                        //음악 진행바
                        Rectangle()
                            .fill(.white.opacity(0.1))  // 배경 회색
                            .frame(height: 3)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(.white)  // 진행된 부분 흰색
                                    .frame(width: 120 * 0.6)  // 60% 진행된 상태
                            }
                            .frame(width: 120)  // 전체 너비
                            .cornerRadius(2)
                        
                        
                        //트랩 선택view
                        HStack(spacing: 14) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 18))
                            
                            Image(systemName: "pause.fill")
                                .font(.system(size: 20))
                            
                            Image(systemName: "forward.fill")
                                .font(.system(size: 18))
                            
                        }
                        .frame(width: 120)
                        .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                
                
                //기능들
                VStack(alignment: .center, spacing: 12) {
                    VStack {
//                        HStack() {
//                            Text("MEMO")
//                                .font(.system(size: 9, weight: .black))
//                                .foregroundColor(Color("memoText"))
//                            
//                            Spacer()
//                                .frame(width: 140)
//
//                        }
//                        .frame(width: 180)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 201, height: 45)
                            .foregroundColor(Color("memoColor"))
                            .overlay {
                                HStack {
                                    
                                    Image(systemName: "pencil.and.scribble")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.7))
                                        .padding(.leading, 12)
                                        
                                    Text("Start Writing...")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.7))
                                        
                                    
                                    Spacer()
                                    
                                    Text("31")
                                        .padding(.trailing)
                                }
                            }
                        
                    }
                    
                    //집중모드, 타이머, 녹화 버튼
                    HStack(spacing: 10) {
                        //집중모드
                        
                        Button(action: {
                            isTap.toggle()
                                if isTap {
                                    enableFocusMode()
                                } else {
                                    disableFocusMode()
                                }
                        }, label: {
                            Circle()
                                .fill(isTap ? Color.blue.opacity(0.2) : Color("3buttonColor"))
                                .frame(width: 35, height: 35)
                                .overlay {
                                    Image(systemName: "moon.fill")
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 14))
                                }
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        Spacer()
                        
                        // 포모도로 타이머
                        Circle()
                            .fill(Color("3buttonColor"))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "timer")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 14))
                            }
                        
                        Spacer()
                        
                        // 화면 녹화
                        Circle()
                            .fill(Color("3buttonColor"))
                            .frame(width: 35, height: 35)
                            .overlay {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 14))
                            }
                    }
                    .frame(width: 180)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    func enableFocusMode() {
        let script = """
        tell application "System Events"
            tell process "ControlCenter"
                try
                    click menu bar item "Control Center" of menu bar 1
                    delay 0.5
                    click button "Focus" of window 1
                end try
            end tell
        end tell
        """
        
        executeAppleScript(script)
    }

    func disableFocusMode() {
        // 같은 방식으로 다시 클릭하여 끄기
        enableFocusMode()
    }

    func executeAppleScript(_ script: String) {
        DispatchQueue.global(qos: .background).async {
            if let appleScript = NSAppleScript(source: script) {
                var error: NSDictionary?
                appleScript.executeAndReturnError(&error)
                if let error = error {
                    print("AppleScript 오류: \(error)")
                }
            }
        }
    }
    struct StudioPlaceholder_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(currentTab: .constant(.studio))
                .environmentObject(NotchViewModel())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: onNotchSize.width, height: onNotchSize.height)
                .background(Color.black)
                .clipShape(NotchShape(cornerRadius: 20))
        }
    }

}

