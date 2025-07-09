//
//  MusicPlayView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/23/25.
//

import SwiftUI

struct MusicPlayerView: View {
    @State private var mediaRemote: MediaRemoteManager?
    
    var body: some View {
        Group {
            if let manager = mediaRemote {
                MusicPlayerContent(manager: manager)
            } else {
                Text("음악 플레이어 로딩 중...")
            }
        }
        .onAppear {
            mediaRemote = MediaRemoteManager()
        }
    }
}


struct MusicPlayerContent: View {
   @ObservedObject var manager: MediaRemoteManager
   @State private var sliderValue: Double = 0
   @State private var isDragging: Bool = false
   
   var body: some View {
       HStack(spacing: 16) {
           VStack {
               // 앨범 아트
               albumArtView
               
               // 곡 정보
               songInfoView
               
           }
           VStack {
               // 진행 바
               progressSliderView
               
               // 재생 시간
               timeLabelsView
               
               // 제어 버튼
               controlButtonsView
           }
       }
       .padding()
       .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
           if !isDragging {
               sliderValue = manager.elapsedTime
           }
       }
   }
   
   // MARK: - Album Art
   private var albumArtView: some View {
       Group {
           if let artworkData = manager.albumArt,
              let image = NSImage(data: artworkData) {
               Image(nsImage: image)
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(width: 120, height: 120)
                   .clipShape(RoundedRectangle(cornerRadius: 12))
                   .shadow(radius: 8)
           } else {
               RoundedRectangle(cornerRadius: 12)
                   .fill(Color.gray.opacity(0.3))
                   .frame(width: 120, height: 120)
                   .overlay {
                       Image(systemName: "music.note")
                           .font(.largeTitle)
                           .foregroundColor(.gray)
                   }
           }
       }
   }
   
   // MARK: - Song Info
   private var songInfoView: some View {
       VStack(spacing: 4) {
           Text(manager.songTitle.isEmpty ? "재생 중인 곡 없음" : manager.songTitle)
               .font(.headline)
               .fontWeight(.semibold)
               .multilineTextAlignment(.center)
               .lineLimit(2)
           
           Text(manager.artistName.isEmpty ? "알 수 없는 아티스트" : manager.artistName)
               .font(.subheadline)
               .foregroundColor(.secondary)
               .multilineTextAlignment(.center)
               .lineLimit(1)
       }
   }
   
   // MARK: - Progress Slider
   private var progressSliderView: some View {
       Slider(
           value: Binding(
               get: { isDragging ? sliderValue : manager.elapsedTime },
               set: { newValue in
                   sliderValue = newValue
                   if !isDragging {
                       manager.seek(to: newValue)
                   }
               }
           ),
           in: 0...max(manager.duration, 1),
           onEditingChanged: { editing in
               isDragging = editing
               if !editing {
                   manager.seek(to: sliderValue)
               }
           }
       )
       .accentColor(.blue)
   }
   
   // MARK: - Time Labels
   private var timeLabelsView: some View {
       HStack {
           Text(timeString(from: isDragging ? sliderValue : manager.elapsedTime))
               .font(.caption)
               .foregroundColor(.secondary)
           
           Spacer()
           
           Text(timeString(from: manager.duration))
               .font(.caption)
               .foregroundColor(.secondary)
       }
   }
   
   // MARK: - Control Buttons
   private var controlButtonsView: some View {
       HStack(spacing: 24) {
           // 이전 곡
           Button(action: manager.previousTrack) {
               Image(systemName: "backward.fill")
                   .font(.title2)
                   .foregroundColor(.primary)
           }
           .buttonStyle(ControlButtonStyle())
           
           // 재생/일시정지
           Button(action: manager.playPause) {
               Image(systemName: manager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                   .font(.system(size: 50))
                   .foregroundColor(.blue)
           }
           .buttonStyle(PlainButtonStyle())
           
           // 다음 곡
           Button(action: manager.nextTrack) {
               Image(systemName: "forward.fill")
                   .font(.title2)
                   .foregroundColor(.primary)
           }
           .buttonStyle(ControlButtonStyle())
       }
   }
   
   // MARK: - Helper Functions
   private func timeString(from seconds: Double) -> String {
       let totalSeconds = Int(seconds)
       let minutes = totalSeconds / 60
       let remainingSeconds = totalSeconds % 60
       return String(format: "%d:%02d", minutes, remainingSeconds)
   }
}

// MARK: - Custom Button Style
struct ControlButtonStyle: ButtonStyle {
   func makeBody(configuration: Configuration) -> some View {
       configuration.label
           .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
           .opacity(configuration.isPressed ? 0.6 : 1.0)
           .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
   }
}

// MARK: - Preview
#Preview {
   if let manager = MediaRemoteManager() {
       MusicPlayerContent(manager: manager)
           .frame(width: 300)
           .padding()
   } else {
       Text("Preview not available")
   }
}
