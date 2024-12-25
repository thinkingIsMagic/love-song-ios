import SwiftUI

struct PlayButton: View {
    @Binding var buttonScale: CGFloat
    @Binding var buttonOpacity: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
} 