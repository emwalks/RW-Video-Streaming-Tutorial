/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import AVFoundation

final class LoopingPlayerUIView: UIView {
  // here we are instructing the LoopingPlayerUIView class to use a AVPlayerLayer instead of a plain CALayer when it wraps the CALayer as a UIView
  override class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
  
  // computed property to set the layer as an AVPlayerLayer - removes need to cast later
  // AVPlayerLayer is  a special CALayer and UI View is a wrapper around a CALayer
  var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  private var player: AVQueuePlayer?
  
  // to use KVO in Swify you need to retain a reference to the observer
  private var token: NSKeyValueObservation?
  
  private var allURLs: [URL]

	init(urls: [URL]) {
		allURLs = urls
    player = AVQueuePlayer()

		super.init(frame: .zero)
    addAllVideosToPlayer()
    
    player?.volume = 0.0
    player?.play()
    
    playerLayer.player = player
    
    // Here, you’re registering a block to run each time the player’s currentItem property changes. When the current video changes, you want to check to see if the player has moved to the final video. If it has, then it’s time to add all the video clips back to the queue.
    
    token = player?.observe(\.currentItem) { [weak self] player, _ in
      if player.items().count == 1 {
        self?.addAllVideosToPlayer()
      }
    }
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
  
  private func addAllVideosToPlayer() {
    for url in allURLs {
      // 1
      let asset = AVURLAsset(url: url)

      // 2
      let item = AVPlayerItem(asset: asset)

      // 3
      player?.insert(item, after: player?.items().last)
    }
  }

  
}

// to be able to use the AVPlayerLayer in SwiftUI we need to wrap it in a UIViewRepresentable
struct LoopingPlayerView: UIViewRepresentable {
  let videoURLs: [URL]
  typealias UIViewType = LoopingPlayerUIView
  
  func makeUIView(context: Context) -> LoopingPlayerUIView {
    let view = LoopingPlayerUIView(urls: videoURLs)
    return view
  }
  
  func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) { }
}

