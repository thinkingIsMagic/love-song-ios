import SwiftUI

struct CloseButton: View {
    let videoLoader: VideoLoader
    let videoScale: CGFloat
    @Binding var isVideoPlaying: Bool
    @Binding var videoScale: CGFloat
    @Binding var buttonScale: CGFloat
    @Binding var buttonOpacity: Double
    
    var body: some View {
        VStack {
            HStack {
                Button(action: handleClose) {
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
    
    private func handleClose() {
        videoLoader.player.pause()
        isVideoPlaying = false
        videoScale = 0.3
        buttonScale = 1.0
        buttonOpacity = 1.0
    }
} 