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
            // 背景色
            Color(red: 255/255, green: 192/255, blue: 203/255)
                .ignoresSafeArea()
            
            if !isVideoPlaying {
                // 播放按钮
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
                            videoLoader.resetToStart()
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
            }
            
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
            print("无法播放音效：\(error.localizedDescription)")
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
        
        // 优化播放器配置
        controller.entersFullScreenWhenPlaybackBegins = false
        controller.exitsFullScreenWhenPlaybackEnds = false
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            isPaused = true
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
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

// 频加载和缓存管理器
class VideoLoader: NSObject, ObservableObject, AVAssetResourceLoaderDelegate {
    let player: AVPlayer
    private let videoURL = URL(string: "https://think-magic-bucket-1.oss-cn-hangzhou.aliyuncs.com/test_video_12_24.mp4")!
    private let cache = URLCache.shared
    
    override init() {
        // 创建带缓存的 AVPlayer
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        // 配置播放项
        playerItem.preferredForwardBufferDuration = 5  // 预缓冲5秒
        playerItem.automaticallyPreservesTimeOffsetFromLive = false
        
        self.player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        
        super.init()
        
        // 使用新的 API 加载视频资源
        Task {
            do {
                // 等待资源加载完成并存储结果
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    print("Asset is not playable")
                    return
                }
                
                // 在主线程上配置缓存
                await MainActor.run {
                    let request = URLRequest(url: videoURL,
                                          cachePolicy: .returnCacheDataElseLoad,
                                          timeoutInterval: 30)
                    
                    if self.cache.cachedResponse(for: request) == nil {
                        // 创建带缓存配置的URLSession
                        let config = URLSessionConfiguration.default
                        config.requestCachePolicy = .returnCacheDataElseLoad
                        let session = URLSession(configuration: config)
                        
                        session.dataTask(with: request) { [weak self] data, response, error in
                            guard let data = data,
                                  let response = response else { return }
                            
                            let cachedResponse = CachedURLResponse(
                                response: response,
                                data: data,
                                userInfo: nil,
                                storagePolicy: .allowed
                            )
                            self?.cache.storeCachedResponse(cachedResponse, for: request)
                        }.resume()
                    }
                }
            } catch {
                print("Failed to load asset: \(error.localizedDescription)")
            }
        }
        
        asset.resourceLoader.setDelegate(self, queue: .main)
    }
    
    func resetToStart() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
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
