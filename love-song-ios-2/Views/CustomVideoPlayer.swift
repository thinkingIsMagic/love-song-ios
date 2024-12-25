import SwiftUI
import AVKit

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