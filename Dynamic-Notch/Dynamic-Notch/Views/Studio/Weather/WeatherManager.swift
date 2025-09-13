//
//  WeatherManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/22/25.
//

//import Foundation
//import CoreLocation
//import SwiftUI
//import WeatherKit
//
//struct WeatherData {
//    let temperature: Double
//    let condition: String
//    let symbolName: String
//    let location: String
//    let lastUpdated: Date
//}
//
//@MainActor
//class WeatherManager: NSObject, ObservableObject {
//    
//    static let shared = WeatherManager()
//    
//    @Published var currentWeather: WeatherData?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
//    @Published var isError: Bool = false
//    
//    private let locationManager = CLLocationManager()
//    private let weatherService = WeatherService.shared
//    
//    override init() {
//        super.init()
//        Task {
//            await setupLocationManager()
//        }
//    }
//    
//    private func setupLocationManager() async {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
//        
//        authorizationStatus = locationManager.authorizationStatus
//        print("🔍 현재 위치 권한 상태: \(authorizationStatusString(authorizationStatus))")
//        
//        if authorizationStatus == .authorizedAlways {
//            await fetchWeather()
//        }
//    }
//    
//    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
//        switch status {
//        case .notDetermined: return "notDetermined"
//        case .restricted: return "restricted"
//        case .denied: return "denied"
//        case .authorizedAlways: return "authorizedAlways"
//        default: return "unknown"
//        }
//    }
//    
//    func requestLocationPermission() async {
//        guard authorizationStatus == .notDetermined else {
//            print("⚠️ 권한이 이미 결정됨: \(authorizationStatusString(authorizationStatus))")
//            return
//        }
//        
//        print("🔍 위치 권한 요청")
//        locationManager.requestAlwaysAuthorization()
//        
//        // 권한 요청 후 잠시 대기
//        try? await Task.sleep(nanoseconds: 2_000_000_000)
//    }
//    
//    func fetchWeather() async {
//        guard authorizationStatus == .authorizedAlways else {
//            await MainActor.run {
//                self.errorMessage = "위치 권한이 필요합니다"
//                self.isError = true
//                self.isLoading = false
//            }
//            return
//        }
//        
//        await MainActor.run {
//            self.isLoading = true
//            self.isError = false
//            self.errorMessage = nil
//        }
//        
//        locationManager.requestLocation()
//    }
//    
//    private func fetchWeather(for location: CLLocation) async {
//        do {
//            print("🌍 WeatherKit API 호출 중...")
//            print("📍 위치: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//            
//            let weather = try await weatherService.weather(for: location)
//            let currentWeather = weather.currentWeather
//            
//            print("✅ WeatherKit 응답 받음")
//            print("🌡️ 온도: \(currentWeather.temperature.value)°C")
//            print("☁️ 상태: \(currentWeather.condition)")
//            
//            // 위치 이름 가져오기
//            let locationName = await getLocationName(for: location)
//            
//            let weatherData = WeatherData(
//                temperature: currentWeather.temperature.value,
//                condition: currentWeather.condition.description,
//                symbolName: currentWeather.symbolName,
//                location: locationName,
//                lastUpdated: currentWeather.date
//            )
//            
//            await MainActor.run {
//                self.currentWeather = weatherData
//                self.isLoading = false
//                self.isError = false
//                self.errorMessage = nil
//            }
//            
//            print("✅ 날씨 데이터 로드 성공: \(weatherData.location) \(Int(weatherData.temperature))°")
//            
//        } catch {
//            print("❌ WeatherKit 오류: \(error)")
//            print("❌ 오류 상세: \(error.localizedDescription)")
//            
//            let errorDescription: String
//            if error.localizedDescription.contains("network") {
//                errorDescription = "네트워크 연결을 확인해주세요"
//            } else if error.localizedDescription.contains("authorization") {
//                errorDescription = "WeatherKit 사용 권한이 필요합니다"
//            } else {
//                errorDescription = "날씨 정보를 가져올 수 없습니다: \(error.localizedDescription)"
//            }
//            
//            await MainActor.run {
//                self.errorMessage = errorDescription
//                self.isError = true
//                self.isLoading = false
//            }
//        }
//    }
//    
//    private func getLocationName(for location: CLLocation) async -> String {
//        do {
//            let geocoder = CLGeocoder()
//            let placemarks = try await geocoder.reverseGeocodeLocation(location)
//            
//            if let placemark = placemarks.first {
//                return placemark.locality ??
//                       placemark.administrativeArea ??
//                       placemark.country ??
//                       "알 수 없는 위치"
//            }
//        } catch {
//            print("⚠️ Geocoding 실패: \(error)")
//        }
//        
//        return "알 수 없는 위치"
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension WeatherManager: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        print("🔍 위치 업데이트: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//        Task {
//            await fetchWeather(for: location)
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("❌ 위치 가져오기 실패: \(error)")
//        Task { @MainActor in
//            self.errorMessage = "위치를 가져올 수 없습니다: \(error.localizedDescription)"
//            self.isError = true
//            self.isLoading = false
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        Task { @MainActor in
//            let oldStatus = self.authorizationStatus
//            self.authorizationStatus = status
//            
//            print("🔍 위치 권한 상태 변경: \(self.authorizationStatusString(oldStatus)) → \(self.authorizationStatusString(status))")
//            
//            switch status {
//            case .authorizedAlways:
//                print("✅ 위치 권한 허용됨 - 날씨 정보 가져오기")
//                self.isError = false
//                self.errorMessage = nil
//                if oldStatus != status {
//                    Task {
//                        await self.fetchWeather()
//                    }
//                }
//                
//            case .denied, .restricted:
//                print("❌ 위치 권한 거부됨")
//                self.errorMessage = "위치 접근이 거부되었습니다. 시스템 환경설정에서 권한을 허용해주세요."
//                self.isError = true
//                self.isLoading = false
//                
//            case .notDetermined:
//                print("❓ 위치 권한 미결정 상태")
//                
//            default:
//                print("❓ 알 수 없는 권한 상태")
//                self.errorMessage = "알 수 없는 위치 권한 상태입니다."
//                self.isError = true
//            }
//        }
//    }
//}
