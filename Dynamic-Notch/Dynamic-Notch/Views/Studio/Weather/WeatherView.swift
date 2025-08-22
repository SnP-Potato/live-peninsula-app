//
//  WeatherView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/22/25.
//
//
//
//  WeatherView.swift
//  boringNotch
//
//  Created by Assistant on 2025-01-26.
//

//
//  WeatherView.swift
//  boringNotch
//
//  Created by Assistant on 2025-01-26.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherManager = WeatherManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            // 권한 상태별 UI 표시
            switch weatherManager.authorizationStatus {
            case .denied, .restricted:
                WeatherNoAccessView()
            case .notDetermined:
                WeatherPermissionView()
            default:
                if weatherManager.isLoading {
                    WeatherLoadingView()
                } else if let weather = weatherManager.currentWeather {
                    WeatherContentView(weather: weather)
                } else if weatherManager.isError {
                    WeatherErrorView()
                } else {
                    WeatherNoDataView()
                }
            }
        }
        .frame(width: 150, height: 110)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        )
        .onAppear {
            checkAndFetchWeather()
        }
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Helper Methods
    private func checkAndFetchWeather() {
        switch weatherManager.authorizationStatus {
        case .notDetermined:
            Task {
                await weatherManager.requestLocationPermissionAsync()
            }
        case .authorizedAlways:
            if weatherManager.currentWeather == nil || weatherManager.shouldRefresh() {
                weatherManager.fetchWeather()
            }
        default:
            break
        }
    }
    
    private func handleTap() {
        switch weatherManager.authorizationStatus {
        case .denied, .restricted:
            openSettings()
        case .notDetermined:
            Task {
                await weatherManager.requestLocationPermissionAsync()
            }
        default:
            weatherManager.refreshWeather()
        }
    }
    
    private func openSettings() {
        #if os(macOS)
        if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(settingsURL)
        }
        #else
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
        #endif
    }
}

// MARK: - 권한 없음 뷰
struct WeatherNoAccessView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.slash")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text("위치 접근 권한 필요")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("설정에서 권한을 허용해주세요")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("설정 열기") {
                #if os(macOS)
                if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                    NSWorkspace.shared.open(settingsURL)
                }
                #endif
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
        }
        .padding(12)
    }
}

// MARK: - 권한 요청 뷰
struct WeatherPermissionView: View {
    @StateObject private var weatherManager = WeatherManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location")
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text("위치 권한 요청")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("날씨 정보를 위해\n위치 권한이 필요합니다")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("권한 요청") {
                Task {
                    await weatherManager.requestLocationPermissionAsync()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
        }
        .padding(12)
    }
}

// MARK: - 로딩 뷰
struct WeatherLoadingView: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.white)
            
            Text("날씨 정보 로딩 중...")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }
}

// MARK: - 에러 뷰
struct WeatherErrorView: View {
    @StateObject private var weatherManager = WeatherManager.shared
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.orange)
            
            Text("날씨 로딩 실패")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            if let error = weatherManager.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            Text("탭해서 다시 시도")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
    }
}

// MARK: - 데이터 없음 뷰
struct WeatherNoDataView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "cloud")
                .font(.title2)
                .foregroundStyle(.gray)
            
            Text("날씨 정보 없음")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("탭해서 새로고침")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }
}

// MARK: - 날씨 콘텐츠 뷰
struct WeatherContentView: View {
    let weather: WeatherData
    @StateObject private var weatherManager = WeatherManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            // 상단: 날씨 아이콘 & 온도
            HStack(spacing: 8) {
                Image(systemName: weather.symbolName)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.multicolor)
                
                VStack(alignment: .leading, spacing: -2) {
                    Text("\(Int(weather.temperature))°")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(weather.condition)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // 하단: 위치 & 업데이트 시간
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "location")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(weather.location)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                HStack {
                    Text("업데이트: \(timeAgoString(from: weather.lastUpdated))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if weatherManager.shouldRefresh() {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "방금"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)분 전"
        } else {
            let hours = Int(timeInterval / 3600)
            return "\(hours)시간 전"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 정상 날씨 데이터
        WeatherView()
            .onAppear {
                let sampleWeather = WeatherData(
                    temperature: 22.0,
                    condition: "맑음",
                    symbolName: "sun.max.fill",
                    location: "서울",
                    description: "맑고 쾌청한 날씨",
                    humidity: 0.65,
                    windSpeed: 12.0,
                    feelsLike: 24.0,
                    lastUpdated: Date()
                )
                WeatherManager.shared.currentWeather = sampleWeather
            }
        
        // 권한 요청 상태
        WeatherPermissionView()
        
        // 권한 거부 상태
        WeatherNoAccessView()
        
        // 로딩 상태
        WeatherLoadingView()
    }
    .padding()
    .background(.black)
}
