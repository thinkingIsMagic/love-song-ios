//
//  ContentView.swift
//  love-song-ios-2
//
//  Created by 王昊 on 2024/12/25.
//

import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @State private var isVideoPlaying = false
    @State private var player = AVPlayer(url: URL(string: "https://think-magic-bucket-1.oss-cn-hangzhou.aliyuncs.com/test_video_12_24.mp4")!)
    @State private var isPaused = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonOpacity: Double = 1.0
    @State private var videoScale: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 192/255, blue: 203/255)
                .ignoresSafeArea()
            
            Button(action: {
                playClickSound()
                withAnimation(.easeOut(duration: 0.2)) {
                    buttonScale = 0.8
                    buttonOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isVideoPlaying = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        videoScale = 1.0
                    }
                    player.play()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                    Text("love song")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundColor(.black)
                .frame(width: 160, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                )
            }
            .scaleEffect(buttonScale)
            .opacity(buttonOpacity)
            
            if isVideoPlaying {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        CustomVideoPlayer(player: player, isPaused: $isPaused)
                            .edgesIgnoringSafeArea(.all)
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .cornerRadius(50)
                            .scaleEffect(videoScale)
                            .opacity(videoScale)
                            .onTapGesture {
                                if isPaused {
                                    player.play()
                                    isPaused = false
                                } else {
                                    player.pause()
                                    isPaused = true
                                }
                            }
                        
                        Button(action: {
                            player.pause()
                            isVideoPlaying = false
                            buttonScale = 1.0
                            buttonOpacity = 1.0
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                )
                        }
                        .opacity(videoScale)
                        .padding(.top, 24)
                        .padding(.leading, 24)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onDisappear {
            player.pause()
        }
    }
    
    private func playClickSound() {
        guard let soundURL = Bundle.main.url(forResource: "click", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.play()
        } catch {
            print("无法播放效：\(error.localizedDescription)")
        }
    }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    @Binding var isPaused: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            isPaused = true
            player.seek(to: .zero)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
