//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

//import SwiftUI
//
//struct StudioPlaceholder: View {
//    
//    @State private var isDND: Bool = false
//    @State private var isTimer: Bool = false
//    @State private var isRecord: Bool = false
//    @State private var isMemo: Bool = false
//    @State private var currentActivity: ActivityFeatures = .none
//    
//    @StateObject private var focusModeManager = FocusModeManager()
//    enum ActivityFeatures {
//        case none
//        case memo
//        case timer
//    }
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            
//            Spacer()
//                .frame(width: 20)
//            
//            // 음악 영역
//            HStack(spacing: 12) {
//                // 음악 이미지
//                Image("musicImage 1")
//                    .resizable()
//                    .frame(width: 100, height: 100)
//                    .scaledToFill()
//                    .cornerRadius(12)
//                    .overlay {
//                        Image("musicApp")
//                            .resizable()
//                            .frame(width: 22, height: 22)
//                            .scaledToFill()
//                            .cornerRadius(6)
//                            .offset(x: 34, y: 34)
//                    }
//                
//                // 음악 정보 및 컨트롤
//                VStack(alignment: .center, spacing: 12) {
//                    
//                    VStack(alignment: .center, spacing: 2) {
//                        Text("Heat Waves")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .lineLimit(1)
//                        
//                        Text("Grass Animals")
//                            .font(.system(size: 11, weight: .regular))
//                            .foregroundColor(Color("artist"))
//                            .lineLimit(1)
//                    }
//                    .frame(width: 140)
//                    
//                    
//                    Rectangle()
//                        .fill(.white.opacity(0.1))
//                        .frame(width: 140, height: 3)
//                        .overlay(alignment: .leading) {
//                            Rectangle()
//                                .fill(.white)
//                                .frame(width: 140 * 0.6) // 60%
//                        }
//                        .cornerRadius(1.5)
//                    
//                    // 컨트롤 버튼
//                    HStack(spacing: 18) {
//                        Button(action: {
//                            //
//                        }) {
//                            Image(systemName: "backward.fill")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(.white)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Button(action: {
//                            //
//                        }) {
//                            Image(systemName: "pause.fill")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(.white)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Button(action: {
//                            //
//                        }) {
//                            Image(systemName: "forward.fill")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(.white)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                    .frame(width: 140)
//                }
//                .frame(width: 140)
//            }
//            .frame(width: 242)
//            
//            Spacer()
//            
//            //다른 기능들
//            VStack(alignment: .center, spacing: 10) {
//                if currentActivity == .none {
//                    DefaultView
//                } else {
//                    SelectedFeatureView
//                }
//            }
//            .frame(width: 180, height: 90)
//            .animation(.easeInOut(duration: 0.2), value: currentActivity)
//            
//            Spacer()
//                .frame(width: 10)
//        }
////        .frame(width: 500, height: 100)
//        .padding(.vertical, 8)
//    }
//    
//    @ViewBuilder
//    private var DefaultView: some View {
//        // 메모 영역
//        Button(action: {
//            isMemo = true
//            currentActivity = .memo
//        }) {
//            RoundedRectangle(cornerRadius: 8)
//                .frame(width: 180, height: 42)
//                .foregroundColor(Color("3buttonColor"))
//                .opacity(0.5)
//                .overlay {
//                    HStack(spacing: 8) {
//                        Image(systemName: "pencil.and.scribble")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        Text("Start Writing...")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        Spacer()
//                        
//                        Text("31")
//                            .font(.system(size: 11, weight: .medium))
//                            .foregroundColor(.gray.opacity(0.7))
//                    }
//                    .padding(.horizontal, 10)
//                }
//        }
//        .buttonStyle(PlainButtonStyle())
//        
//        // 집중모드 & 타이머 & 화면녹화 기능들
//        HStack(spacing: 20) {
//            // 집중모드
//            Button(action: {
//                isDND.toggle()
//            }) {
//                Circle()
//                    .fill(isDND ? Color.blue.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.5)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: "moon.fill")
//                            .foregroundStyle(.blue)
//                            .font(.system(size: 16))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            //  타이머
//            Button(action: {
//                isTimer = true
//                currentActivity = .timer
//            }) {
//                Circle()
//                    .fill(isTimer ? Color.orange.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.5)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: "timer")
//                            .foregroundStyle(.orange)
//                            .font(.system(size: 16))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            // 화면 녹화
//            Button(action: {
//                isRecord.toggle()
//            }) {
//                Circle()
//                    .fill(isRecord ? Color.red.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.5)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: "record.circle")
//                            .foregroundStyle(.red)
//                            .font(.system(size: 20))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//    }
//    
//    @ViewBuilder
//    private var SelectedFeatureView: some View {
//        VStack {
//            
//            HStack {
//                Spacer()
//                
//                Button(action: {
//                    resetToDefaultView()
//                }, label: {
//                    Image(systemName: "x.circle")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.gray)
//                })
//                .buttonStyle(PlainButtonStyle())
//            }
//            
//            Group {
//                switch currentActivity {
//                case .none:
//                    EmptyView()
//                case .memo:
//                    MemoFeatureView()
//                case .timer:
//                    TimerFeatureView()
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            Spacer()
//        }
//    }
//    private func resetToDefaultView() {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            currentActivity = .none
//            isMemo = false
//            isTimer = false
//            // isRecord와 isDND는 토글 형태이므로 유지
//        }
//    }
//}
//
//
////// MARK: - 각 기능별 뷰들
//struct MemoFeatureView: View {
//    var body: some View {
//        VStack {
//            Text("메모")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white)
//            Text("메모 기능이 여기에 표시됩니다")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//        }
//    }
//}
//
//struct TimerFeatureView: View {
//    
//    var body: some View {
//        VStack {
//            Image(systemName: "timer")
//                .foregroundStyle(.orange)
//                .font(.system(size: 20))
//            Text("타이머")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white)
//            Text("00:00:00")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.orange)
//        }
//    }
//}
//
//struct StudioPlaceholder_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(currentTab: .constant(.studio))
//            .environmentObject(NotchViewModel())
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .frame(width: onNotchSize.width, height: onNotchSize.height)
//            .background(Color.black)
//            .clipShape(NotchShape(cornerRadius: 20))
//    }
//}
//
//

//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    
    @State private var isTimer: Bool = false
    @State private var isMemo: Bool = false
    @State private var currentActivity: ActivityFeatures = .none
    @State private var isRecord: Bool = false
    
    @EnvironmentObject var focusManager: FocusManager
     //
    
    enum ActivityFeatures {
        case none
        case memo
        case timer
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            Spacer()
                .frame(width: 20)
            
            // 음악 영역
            HStack(spacing: 12) {
                // 음악 이미지
                Image("musicImage 1")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaledToFill()
                    .cornerRadius(12)
                    .overlay {
                        Image("musicApp")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .scaledToFill()
                            .cornerRadius(6)
                            .offset(x: 34, y: 34)
                    }
                
                // 음악 정보 및 컨트롤
                VStack(alignment: .center, spacing: 12) {
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Heat Waves")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("Grass Animals")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                    .frame(width: 140)
                    
                    
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 140, height: 3)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 140 * 0.6) // 60%
                        }
                        .cornerRadius(1.5)
                    
                    // 컨트롤 버튼
                    HStack(spacing: 18) {
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 140)
                }
                .frame(width: 140)
            }
            .frame(width: 242)
            
            Spacer()
            
            //다른 기능들
            VStack(alignment: .center, spacing: 10) {
                if currentActivity == .none {
                    DefaultView
                } else {
                    SelectedFeatureView
                }
            }
            .frame(width: 180, height: 90)
            .animation(.easeInOut(duration: 0.2), value: currentActivity)
            
            Spacer()
                .frame(width: 10)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var DefaultView: some View {
        // 메모 영역
        Button(action: {
            isMemo = true
            currentActivity = .memo
        }) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 180, height: 42)
                .foregroundColor(Color("3buttonColor"))
                .opacity(0.5)
                .overlay {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("Start Writing...")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Spacer()
                        
                        Text("31")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                }
        }
        .buttonStyle(PlainButtonStyle())
        
        // 집중모드 & 타이머 & 화면녹화 기능들
        HStack(spacing: 20) {
            // 집중모드 - 글로벌 상태 사용
            Button(action: {
                print("🌙 집중모드 버튼 클릭! (글로벌)")
                focusManager.toggleFocusMode()
            }) {
                Circle()
                    .fill(focusManager.isFocused ? Color.blue.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(focusManager.isFocused ? .blue : .blue)
                            .font(.system(size: 16))
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            //  타이머
            Button(action: {
                isTimer = true
                currentActivity = .timer
            }) {
                Circle()
                    .fill(isTimer ? Color.orange.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "timer")
                            .foregroundStyle(.orange)
                            .font(.system(size: 16))
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 화면 녹화 - 간단한 토글
            Button(action: {
                print("🔴 화면 녹화 버튼 클릭!")
                isRecord.toggle()
                print("💡 Cmd + Shift + 5를 직접 눌러서 화면 녹화를 시작하세요")
            }) {
                Circle()
                    .fill(isRecord ? Color.red.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: isRecord ? "record.circle.fill" : "record.circle")
                            .foregroundStyle(.red)
                            .font(.system(size: 20))
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder
    private var SelectedFeatureView: some View {
        VStack {
            
            HStack {
                Spacer()
                
                Button(action: {
                    resetToDefaultView()
                }, label: {
                    Image(systemName: "x.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                })
                .buttonStyle(PlainButtonStyle())
            }
            
            Group {
                switch currentActivity {
                case .none:
                    EmptyView()
                case .memo:
                    MemoFeatureView()
                case .timer:
                    TimerFeatureView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
    }
    
    private func resetToDefaultView() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentActivity = .none
            isMemo = false
            isTimer = false
            // 집중모드와 화면녹화는 독립적으로 유지
        }
    }
}

// MARK: - 각 기능별 뷰들
struct MemoFeatureView: View {
    var body: some View {
        VStack {
            Text("메모")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text("메모 기능이 여기에 표시됩니다")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

struct TimerFeatureView: View {
    var body: some View {
        VStack {
            Image(systemName: "timer")
                .foregroundStyle(.orange)
                .font(.system(size: 20))
            Text("타이머")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text("00:00:00")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.orange)
        }
    }
}

struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentTab: .constant(.studio))
            .environmentObject(NotchViewModel())
            .environmentObject(FocusManager.shared)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: onNotchSize.width, height: onNotchSize.height)
            .background(Color.black)
            .clipShape(NotchShape(cornerRadius: 20))
    }
}
