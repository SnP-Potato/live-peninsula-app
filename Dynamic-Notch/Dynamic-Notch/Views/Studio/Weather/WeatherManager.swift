//////
//////  WeatherManager.swift
//////  Dynamic-Notch
//////
//////  Created by PeterPark on 8/22/25.
//////
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
//    let description: String
//    let humidity: Double
//    let windSpeed: Double
//    let feelsLike: Double
//    let lastUpdated: Date
//}
//
//class WeatherManager: NSObject, ObservableObject {
//    static let shared = WeatherManager()
//    
//    @Published var currentWeather: WeatherData?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
//    @Published var isError: Bool = false
//    
//    private let locationManager = CLLocationManager()
//    private let weatherService = WeatherService()
//    private var hasRequestedPermission = false
//    private var lastFetchTime: Date?
//    
//    private override init() {
//        super.init()
//        setupLocationManager()
//        checkLocationPermission()
//    }
//    
//    // MARK: - Location Setup
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
//        locationManager.distanceFilter = 1000 // 1km 이상 이동시에만 업데이트
//    }
//    
//    private func checkLocationPermission() {
//        authorizationStatus = locationManager.authorizationStatus
//        print("📍 초기 위치 권한 상태: \(authorizationStatusString(authorizationStatus))")
//        
//        // 이미 권한이 있으면 즉시 날씨 정보 가져오기
//        if authorizationStatus == .authorizedAlways {
//            fetchWeather()
//        }
//    }
//    
//    // 권한 상태를 문자열로 변환하는 헬퍼 함수
//    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
//        switch status {
//        case .notDetermined: return "notDetermined"
//        case .restricted: return "restricted"
//        case .denied: return "denied"
//        case .authorizedAlways: return "authorizedAlways"
//        case .authorizedWhenInUse: return "authorizedWhenInUse"
//        @unknown default: return "unknown"
//        }
//    }
//    
//    // async 권한 요청 함수
//    func requestLocationPermissionAsync() async {
//        guard authorizationStatus == .notDetermined else {
//            print("⚠️ 권한이 이미 결정됨: \(authorizationStatusString(authorizationStatus))")
//            return
//        }
//        
//        guard !hasRequestedPermission else {
//            print("⚠️ 이미 권한 요청했음 - 중복 요청 방지")
//            return
//        }
//        
//        await MainActor.run {
//            hasRequestedPermission = true
//            print("📍 macOS 위치 권한 요청 실행")
//            locationManager.requestAlwaysAuthorization()
//        }
//        
//        // 권한 요청 후 잠시 대기
//        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2초 대기
//    }
//    
//    private func fetchCurrentLocation() {
//        guard authorizationStatus == .authorizedAlways else {
//            DispatchQueue.main.async {
//                self.errorMessage = "위치 권한이 필요합니다. 시스템 환경설정에서 위치 서비스를 허용해주세요."
//                self.isError = true
//                self.isLoading = false
//            }
//            return
//        }
//        
//        // 너무 자주 요청하지 않도록 체크
//        if let lastFetch = lastFetchTime,
//           Date().timeIntervalSince(lastFetch) < 300 { // 5분 이내 재요청 방지
//            print("⏰ 최근에 날씨 정보를 가져왔음 - 재요청 방지")
//            return
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//            self.isError = false
//            self.errorMessage = nil
//        }
//        
//        locationManager.requestLocation()
//    }
//    
//    // MARK: - WeatherKit Integration
//    func fetchWeather() {
//        print("🌤️ 날씨 정보 가져오기 시작")
//        fetchCurrentLocation()
//    }
//    
//    private func fetchWeather(for location: CLLocation) {
//        Task {
//            await performWeatherKitFetch(for: location)
//        }
//    }
//    
//    @MainActor
//    private func performWeatherKitFetch(for location: CLLocation) async {
//        do {
//            print("🌐 WeatherKit API 호출 중...")
//            let weather = try await weatherService.weather(for: location)
//            let currentWeather = weather.currentWeather
//            
//            // 위치 이름 가져오기 (Reverse Geocoding)
//            let locationName = await getLocationName(for: location)
//            
//            // WeatherData 구조체로 변환
//            let weatherData = WeatherData(
//                temperature: currentWeather.temperature.value,
//                condition: translateWeatherCondition(currentWeather.condition),
//                symbolName: currentWeather.symbolName,
//                location: locationName,
//                description: currentWeather.condition.description,
//                humidity: currentWeather.humidity,
//                windSpeed: currentWeather.wind.speed.value * 3.6, // m/s to km/h
//                feelsLike: currentWeather.apparentTemperature.value,
//                lastUpdated: currentWeather.date
//            )
//            
//            self.currentWeather = weatherData
//            self.lastFetchTime = Date()
//            self.isLoading = false
//            self.isError = false
//            self.errorMessage = nil
//            
//            print("✅ WeatherKit 데이터 로드 성공: \(weatherData.location) \(Int(weatherData.temperature))°")
//            
//        } catch {
//            print("❌ WeatherKit 에러: \(error)")
//            let errorDescription: String
//            
//            // WeatherKit의 실제 에러 처리
//            if error.localizedDescription.contains("network") || error.localizedDescription.contains("Network") {
//                errorDescription = "네트워크 연결을 확인해주세요"
//            } else if error.localizedDescription.contains("unavailable") || error.localizedDescription.contains("Unavailable") {
//                errorDescription = "WeatherKit 서비스를 사용할 수 없습니다"
//            } else if error.localizedDescription.contains("authorization") || error.localizedDescription.contains("Authorization") {
//                errorDescription = "WeatherKit 사용 권한이 필요합니다"
//            } else if error.localizedDescription.contains("quota") || error.localizedDescription.contains("Quota") {
//                errorDescription = "일일 요청 한도를 초과했습니다"
//            } else {
//                errorDescription = "날씨 정보를 가져올 수 없습니다: \(error.localizedDescription)"
//            }
//            
//            self.errorMessage = errorDescription
//            self.isError = true
//            self.isLoading = false
//        }
//    }
//    
//    // MARK: - Location Name Resolution
//    private func getLocationName(for location: CLLocation) async -> String {
//        do {
//            let geocoder = CLGeocoder()
//            let placemarks = try await geocoder.reverseGeocodeLocation(location)
//            
//            if let placemark = placemarks.first {
//                // 도시명 우선, 없으면 지역명
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
//    
//    // MARK: - Weather Condition Translation
//    private func translateWeatherCondition(_ condition: WeatherCondition) -> String {
//        switch condition {
//        case .clear: return "맑음"
//        case .mostlyClear: return "대체로 맑음"
//        case .partlyCloudy: return "구름 조금"
//        case .mostlyCloudy: return "구름 많음"
//        case .cloudy: return "흐림"
//        case .foggy: return "안개"
//        case .haze: return "연무"
//        case .smoky: return "연기"
//        case .breezy: return "바람"
//        case .windy: return "강풍"
//        case .drizzle: return "이슬비"
//        case .rain: return "비"
//        case .heavyRain: return "폭우"
//        case .isolatedThunderstorms: return "국지성 뇌우"
//        case .scatteredThunderstorms: return "산발성 뇌우"
//        case .strongStorms: return "강한 폭풍"
//        case .thunderstorms: return "뇌우"
//        case .frigid: return "혹한"
//        case .hail: return "우박"
//        case .hot: return "폭염"
//        case .flurries: return "눈날림"
//        case .sleet: return "진눈깨비"
//        case .snow: return "눈"
//        case .sunShowers: return "소나기"
//        case .wintryMix: return "겨울 강수"
//        case .blizzard: return "눈보라"
//        case .blowingSnow: return "날리는 눈"
//        case .freezingDrizzle: return "어는 이슬비"
//        case .freezingRain: return "어는 비"
//        case .heavySnow: return "폭설"
//        case .hurricane: return "허리케인"
//        case .tropicalStorm: return "열대성 폭풍"
//        default: return condition.description
//        }
//    }
//    
//    // MARK: - Helper Methods
//    func temperatureString() -> String {
//        guard let weather = currentWeather else { return "--°" }
//        return "\(Int(weather.temperature))°"
//    }
//    
//    func conditionIcon() -> String {
//        guard let weather = currentWeather else { return "cloud" }
//        return weather.symbolName
//    }
//    
//    func shouldRefresh() -> Bool {
//        guard let weather = currentWeather else { return true }
//        let timeInterval = Date().timeIntervalSince(weather.lastUpdated)
//        return timeInterval > 600 // 10분마다 새로고침
//    }
//    
//    // MARK: - Manual Refresh
//    func refreshWeather() {
//        print("🔄 날씨 정보 수동 새로고침")
//        lastFetchTime = nil // 시간 제한 무시
//        fetchWeather()
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension WeatherManager: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        print("📍 위치 업데이트: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//        fetchWeather(for: location)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("❌ 위치 가져오기 실패: \(error)")
//        DispatchQueue.main.async {
//            self.errorMessage = "위치를 가져올 수 없습니다: \(error.localizedDescription)"
//            self.isError = true
//            self.isLoading = false
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        DispatchQueue.main.async {
//            let oldStatus = self.authorizationStatus
//            self.authorizationStatus = status
//            
//            print("📍 위치 권한 상태 변경: \(self.authorizationStatusString(oldStatus)) → \(self.authorizationStatusString(status))")
//            
//            switch status {
//            case .authorizedAlways:
//                print("✅ 위치 권한 허용됨 - 날씨 정보 가져오기")
//                self.isError = false
//                self.errorMessage = nil
//                if oldStatus != .authorizedAlways {
//                    self.fetchWeather()
//                }
//                
//            case .denied, .restricted:
//                print("❌ 위치 권한 거부됨")
//                self.errorMessage = "위치 접근이 거부되었습니다. 시스템 환경설정 > 보안 및 개인정보보호 > 위치 서비스에서 권한을 허용해주세요."
//                self.isError = true
//                self.isLoading = false
//                
//            case .notDetermined:
//                print("❓ 위치 권한 미결정 상태")
//                
//            case .authorizedWhenInUse:
//                print("⚠️ macOS에서는 Always 권한이 필요함")
//                self.errorMessage = "백그라운드 날씨 업데이트를 위해 '항상 허용' 권한이 필요합니다."
//                self.isError = true
//                
//            @unknown default:
//                print("❓ 알 수 없는 권한 상태")
//                self.errorMessage = "알 수 없는 위치 권한 상태입니다."
//                self.isError = true
//            }
//        }
//    }
//}
