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
    @State private var isPaused = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonOpacity: Double = 1.0
    @State private var videoScale: CGFloat = 0.3
    @StateObject private var videoLoader = VideoLoader()
    
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
                    videoScale = 0.3
                    isVideoPlaying = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        videoScale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        videoLoader.player.play()
                    }
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
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    CustomVideoPlayer(player: videoLoader.player, isPaused: $isPaused)
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(50)
                        .scaleEffect(videoScale)
                        .opacity(videoScale)
                        .onTapGesture {
                            if isPaused {
                                videoLoader.player.play()
                                isPaused = false
                            } else {
                                videoLoader.player.pause()
                                isPaused = true
                            }
                        }
                    
                    VStack {
                        HStack {
                            Button(action: {
                                videoLoader.player.pause()
                                isVideoPlaying = false
                                videoScale = 0.3
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
                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.leading, 24)
                        Spacer()
                    }
                }
            }
        }
        .onDisappear {
            videoLoader.player.pause()
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
        controller.videoGravity = .resizeAspect
        
        controller.view.backgroundColor = .clear
        
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
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.videoGravity = .resizeAspect
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// 视频加载和缓存管理器
class VideoLoader: NSObject, ObservableObject, AVAssetResourceLoaderDelegate {
    let player: AVPlayer
    private let videoURL = URL(string: "https://think-magic-bucket-1.oss-cn-hangzhou.aliyuncs.com/test_video_12_24.mp4")!
    private let cache = URLCache.shared
    
    override init() {
        // 创建带缓存的 AVPlayer
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        super.init()
        
        // 配置缓存
        let request = URLRequest(url: videoURL)
        let session = URLSession.shared
        
        // 检查缓存
        if cache.cachedResponse(for: request) == nil {
            // 如果没有缓存，下载视频
            session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self,
                      let data = data,
                      let response = response else { return }
                
                // 保存到缓存
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedResponse, for: request)
            }.resume()
        }
        
        // 配置 AVAssetResourceLoader
        asset.resourceLoader.setDelegate(self, queue: .main)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                       shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.request.url else { return false }
        
        // 检查缓存
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request) {
            // 使用缓存的数据
            loadingRequest.dataRequest?.respond(with: cachedResponse.data)
            loadingRequest.finishLoading()
            return true
        }
        
        return false
    }
}
