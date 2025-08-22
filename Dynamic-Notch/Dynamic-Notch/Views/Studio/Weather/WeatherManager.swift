//
//  WeatherManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/22/25.
//

//
//  WeatherManager.swift
//  boringNotch
//
//  Created by Assistant on 2025-01-26.
//

import Foundation
import CoreLocation
import SwiftUI

struct WeatherData {
    let temperature: Double
    let condition: String
    let symbolName: String
    let location: String
    let description: String
    let humidity: Double
    let windSpeed: Double
    let feelsLike: Double
    let lastUpdated: Date
}

// OpenWeatherMap API Response Models
struct OpenWeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Double
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
        let icon: String
    }
    
    struct Wind: Codable {
        let speed: Double
    }
}

class WeatherManager: NSObject, ObservableObject {
    static let shared = WeatherManager()
    
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isError: Bool = false
    
    private let locationManager = CLLocationManager()
    private let apiKey = "YOUR_API_KEY_HERE" // OpenWeatherMap API 키
    private var hasRequestedPermission = false // 중복 요청 방지
    
    private override init() {
        super.init()
        setupLocationManager()
        checkLocationPermission()
        
        // 앱 시작 시 한 번만 권한 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestInitialPermissionIfNeeded()
        }
    }
    
    // MARK: - Location Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    private func checkLocationPermission() {
        authorizationStatus = locationManager.authorizationStatus
        print("🔐 초기 위치 권한 상태: \(authorizationStatus)")
    }
    
    // 초기 권한 요청 (한 번만)
    private func requestInitialPermissionIfNeeded() {
        guard !hasRequestedPermission && authorizationStatus == .notDetermined else {
            if authorizationStatus == .authorizedAlways {
                print("✅ 이미 위치 권한 있음 - 날씨 정보 가져오기")
                fetchWeather()
            }
            return
        }
        
        print("🔐 초기 위치 권한 요청 시작")
        hasRequestedPermission = true
        requestLocationPermission()
    }
    
    // async 권한 요청 함수 (UI에서 호출용)
    func requestLocationPermissionAsync() async {
        guard !hasRequestedPermission else {
            print("⚠️ 이미 권한 요청했음 - 중복 요청 방지")
            return
        }
        
        await withCheckedContinuation { continuation in
            hasRequestedPermission = true
            requestLocationPermission()
            
            // 권한 응답 대기
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                continuation.resume()
            }
        }
    }
    
    private func requestLocationPermission() {
        print("🔐 위치 권한 요청 실행")
        print("🔐 현재 상태: \(authorizationStatus)")
        
        guard authorizationStatus == .notDetermined else {
            print("⚠️ 권한 상태가 notDetermined가 아님: \(authorizationStatus)")
            return
        }
        
        #if os(macOS)
        locationManager.requestAlwaysAuthorization()
        print("🔐 macOS - requestAlwaysAuthorization() 호출")
        #else
        locationManager.requestWhenInUseAuthorization()
        print("🔐 iOS - requestWhenInUseAuthorization() 호출")
        #endif
    }
    
    private func fetchCurrentLocation() {
        guard authorizationStatus == .authorizedAlways else {
            DispatchQueue.main.async {
                self.errorMessage = "Location permission not granted."
                self.isError = true
            }
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - Weather Fetching
    func fetchWeather() {
        fetchCurrentLocation()
    }
    
    private func fetchWeather(for location: CLLocation) {
        Task {
            await performWeatherFetch(for: location)
        }
    }
    
    @MainActor
    private func performWeatherFetch(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            errorMessage = "API key not configured"
            isLoading = false
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            
            let weatherData = WeatherData(
                temperature: response.main.temp,
                condition: response.weather.first?.main ?? "Unknown",
                symbolName: mapWeatherIconToSF(response.weather.first?.icon ?? ""),
                location: response.name,
                description: response.weather.first?.description ?? "No description",
                humidity: response.main.humidity / 100.0,
                windSpeed: response.wind.speed * 3.6, // Convert m/s to km/h
                feelsLike: response.main.feels_like,
                lastUpdated: Date()
            )
            
            currentWeather = weatherData
            isLoading = false
            
        } catch {
            errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Weather Icon Mapping
    private func mapWeatherIconToSF(_ iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    // MARK: - Helper Methods
    func temperatureString() -> String {
        guard let weather = currentWeather else { return "--°" }
        return "\(Int(weather.temperature))°"
    }
    
    func conditionIcon() -> String {
        guard let weather = currentWeather else { return "cloud" }
        return weather.symbolName
    }
    
    func shouldRefresh() -> Bool {
        guard let weather = currentWeather else { return true }
        let timeInterval = Date().timeIntervalSince(weather.lastUpdated)
        return timeInterval > 600 // Refresh every 10 minutes
    }
    
    // MARK: - Manual Refresh
    func refreshWeather() {
        fetchWeather()
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            let oldStatus = self.authorizationStatus
            self.authorizationStatus = status
            
            print("🔐 위치 권한 상태 변경: \(oldStatus) → \(status)")
            
            switch status {
            case .authorizedAlways:
                print("✅ 위치 권한 허용됨 - 날씨 정보 가져오기 시작")
                self.isError = false
                self.errorMessage = nil
                // 권한이 새로 허용된 경우에만 날씨 정보 가져오기
                if oldStatus != .authorizedAlways {
                    self.fetchWeather()
                }
                
            case .denied, .restricted:
                print("❌ 위치 권한 거부됨")
                self.errorMessage = "위치 접근이 거부되었습니다. 설정에서 권한을 허용해주세요."
                self.isError = true
                self.isLoading = false
                
            case .notDetermined:
                print("❓ 위치 권한 미결정 상태")
                
            @unknown default:
                print("❓ 알 수 없는 권한 상태")
                self.errorMessage = "알 수 없는 위치 권한 상태입니다."
                self.isError = true
            }
        }
    }
}
