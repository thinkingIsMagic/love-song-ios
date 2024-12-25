import AVKit
import AVFoundation

class VideoLoader: NSObject, ObservableObject, AVAssetResourceLoaderDelegate {
    let player: AVPlayer
    private let videoURL = URL(string: "https://think-magic-bucket-1.oss-cn-hangzhou.aliyuncs.com/test_video_12_24.mp4")!
    private let cache = URLCache.shared
    
    override init() {
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        playerItem.preferredForwardBufferDuration = 5
        playerItem.automaticallyPreservesTimeOffsetFromLive = false
        
        self.player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        
        super.init()
        
        Task {
            do {
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    print("Asset is not playable")
                    return
                }
                
                await MainActor.run {
                    configureCache()
                }
            } catch {
                print("Failed to load asset: \(error.localizedDescription)")
            }
        }
        
        asset.resourceLoader.setDelegate(self, queue: .main)
    }
    
    private func configureCache() {
        let request = URLRequest(url: videoURL,
                               cachePolicy: .returnCacheDataElseLoad,
                               timeoutInterval: 30)
        
        if self.cache.cachedResponse(for: request) == nil {
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
    
    func resetToStart() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                       shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request) {
            loadingRequest.dataRequest?.respond(with: cachedResponse.data)
            loadingRequest.finishLoading()
            return true
        }
        
        return false
    }
} 