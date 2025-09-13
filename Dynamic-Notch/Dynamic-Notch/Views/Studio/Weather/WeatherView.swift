//
//  WeatherView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/22/25.
//
//
//
//
//import SwiftUI
//import CoreLocation
//
//struct WeatherView: View {
//    @StateObject private var weatherManager = WeatherManager.shared
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // 권한 상태별 UI 표시
//            switch weatherManager.authorizationStatus {
//            case .denied, .restricted:
//                WeatherNoAccessView()
//            case .notDetermined:
//                WeatherPermissionView()
//            default:
//                if weatherManager.isLoading {
//                    WeatherLoadingView()
//                } else if let weather = weatherManager.currentWeather {
//                    WeatherContentView(weather: weather)
//                } else if weatherManager.isError {
//                    WeatherErrorView(errorMessage: weatherManager.errorMessage ?? "알 수 없는 오류")
//                } else {
//                    WeatherNoDataView()
//                }
//            }
//        }
//        .frame(width: 120, height: 110)
//        .onAppear {
//            Task {
//                await checkAndFetchWeather()
//            }
//        }
//        .onTapGesture {
//            Task {
//                await handleTap()
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods
//    private func checkAndFetchWeather() async {
//        switch weatherManager.authorizationStatus {
//        case .notDetermined:
//            await weatherManager.requestLocationPermissionAsync()
//        case .authorizedAlways, .authorizedWhenInUse:
//            if weatherManager.currentWeather == nil || weatherManager.shouldRefresh() {
//                await weatherManager.fetchWeather()
//            }
//        default:
//            break
//        }
//    }
//    
//    private func handleTap() async {
//        switch weatherManager.authorizationStatus {
//        case .denied, .restricted:
//            openSettings()
//        case .notDetermined:
//            await weatherManager.requestLocationPermissionAsync()
//        default:
//            weatherManager.refreshWeather()
//        }
//    }
//    
//    private func openSettings() {
//        #if os(macOS)
//        if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
//            NSWorkspace.shared.open(settingsURL)
//        }
//        #endif
//    }
//}
//
//// MARK: - 권한 없음 뷰
//struct WeatherNoAccessView: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "location.slash")
//                .font(.title2)
//                .foregroundColor(.orange)
//            
//            Text("Location Access")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.white)
//            
//            Text("Required")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//            
//            Text("Tap to open Settings")
//                .font(.system(size: 8))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(8)
//    }
//}
//
//// MARK: - 권한 요청 뷰
//struct WeatherPermissionView: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "location")
//                .font(.title2)
//                .foregroundColor(.blue)
//            
//            Text("Weather")
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.white)
//            
//            Text("Location Required")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//            
//            Text("Tap to allow")
//                .font(.system(size: 8))
//                .foregroundColor(.blue)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(8)
//    }
//}
//
//// MARK: - 로딩 뷰
//struct WeatherLoadingView: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            ProgressView()
//                .scaleEffect(0.6)
//                .tint(.white)
//            
//            Text("Loading")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//            
//            Text("Weather...")
//                .font(.system(size: 8))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(8)
//    }
//}
//
//// MARK: - 에러 뷰
//struct WeatherErrorView: View {
//    let errorMessage: String
//    @StateObject private var weatherManager = WeatherManager.shared
//    
//    var body: some View {
//        VStack(spacing: 6) {
//            Image(systemName: "exclamationmark.triangle")
//                .font(.title2)
//                .foregroundStyle(.orange)
//            
//            Text("Weather Error")
//                .font(.system(size: 10, weight: .medium))
//                .foregroundStyle(.white)
//            
//            Text("Tap to retry")
//                .font(.system(size: 8))
//                .foregroundStyle(.gray)
//            
//            // 디버그 정보 (개발 중에만 표시)
//            #if DEBUG
//            Text(errorMessage)
//                .font(.system(size: 6))
//                .foregroundStyle(.red)
//                .multilineTextAlignment(.center)
//                .lineLimit(3)
//                .padding(.top, 2)
//            #endif
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(8)
//    }
//}
//
//// MARK: - 데이터 없음 뷰
//struct WeatherNoDataView: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "cloud")
//                .font(.title2)
//                .foregroundStyle(.gray)
//            
//            Text("No Weather")
//                .font(.system(size: 10))
//                .foregroundStyle(.gray)
//            
//            Text("Tap to refresh")
//                .font(.system(size: 8))
//                .foregroundStyle(.gray)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(8)
//    }
//}
//
//// MARK: - 날씨 콘텐츠 뷰
//struct WeatherContentView: View {
//    let weather: WeatherData
//    @StateObject private var weatherManager = WeatherManager.shared
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            
//            Spacer()
//                .frame(height: 8)
//            
//            // 상단: 날씨 아이콘과 온도
//            HStack(spacing: 6) {
//                Image(systemName: weather.symbolName)
//                    .font(.title2)
//                    .foregroundStyle(.white)
//                    .symbolRenderingMode(.multicolor)
//                
//                Text("\(Int(weather.temperature))°")
//                    .font(.title)
//                    .fontWeight(.light)
//                    .foregroundStyle(.white)
//                
//                Spacer()
//            }
//            
//            Spacer()
//                .frame(height: 12)
//            
//            // 하단: 위치 정보
//            HStack {
//                Text(weather.location)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundStyle(.white)
//                    .lineLimit(1)
//                
//                Spacer()
//            }
//            
//            // 날씨 상태
//            HStack {
//                Text(weather.condition)
//                    .font(.system(size: 11))
//                    .foregroundStyle(.gray)
//                    .lineLimit(1)
//                
//                Spacer()
//            }
//            
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    VStack(spacing: 20) {
//        // 정상 날씨 데이터
//        WeatherView()
//            .onAppear {
//                let sampleWeather = WeatherData(
//                    temperature: 1.0,
//                    condition: "Light Rain",
//                    symbolName: "cloud.drizzle.fill",
//                    location: "New York",
//                    description: "가벼운 비",
//                    humidity: 0.85,
//                    windSpeed: 12.0,
//                    feelsLike: -1.0,
//                    lastUpdated: Date()
//                )
//                WeatherManager.shared.currentWeather = sampleWeather
//            }
//        
//        // 권한 요청 상태
//        WeatherPermissionView()
//        
//        // 권한 거부 상태
//        WeatherNoAccessView()
//        
//        // 로딩 상태
//        WeatherLoadingView()
//        
//        // 에러 상태
//        WeatherErrorView(errorMessage: "네트워크 연결을 확인해주세요")
//    }
//    .frame(width: 120, height: 110)
//    .padding()
//    .background(.black)
//}
