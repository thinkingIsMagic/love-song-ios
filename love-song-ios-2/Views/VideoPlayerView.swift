import SwiftUI

struct VideoPlayerView: View {
    let videoLoader: VideoLoader
    @Binding var isPaused: Bool
    @Binding var videoScale: CGFloat
    @Binding var isVideoPlaying: Bool
    @Binding var buttonScale: CGFloat
    @Binding var buttonOpacity: Double
    
    var body: some View {
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
            
            CloseButton(
                videoLoader: videoLoader,
                videoScale: videoScale,
                isVideoPlaying: $isVideoPlaying,
                videoScale: $videoScale,
                buttonScale: $buttonScale,
                buttonOpacity: $buttonOpacity
            )
        }
    }
} 