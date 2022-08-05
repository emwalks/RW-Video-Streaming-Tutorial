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
import AVKit

struct LoopingPlayerView: UIViewRepresentable {
  class Coordinator: NSObject, AVPlayerViewControllerDelegate, AVPictureInPictureControllerDelegate {
    private let parent: LoopingPlayerView

    var pipController: AVPictureInPictureController? {
      didSet {
        pipController?.delegate = self
      }
    }

    init(_ parent: LoopingPlayerView) {
      self.parent = parent
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
      parent.shouldOpenPiP = false
      completionHandler(true)
    }
  }

  let videoURLs: [URL]

  @Binding var rate: Float
  @Binding var volume: Float
  @Binding var shouldOpenPiP: Bool

  func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
    uiView.setVolume(volume)
    uiView.setRate(rate)
    if shouldOpenPiP && context.coordinator.pipController?.isPictureInPictureActive == false {
      context.coordinator.pipController?.startPictureInPicture()
    } else if !shouldOpenPiP && context.coordinator.pipController?.isPictureInPictureActive == true {
      context.coordinator.pipController?.stopPictureInPicture()
    }
  }

  func makeUIView(context: Context) -> LoopingPlayerUIView {
    let view = LoopingPlayerUIView(urls: videoURLs)
    view.setVolume(volume)
    view.setRate(rate)

    context.coordinator.pipController = AVPictureInPictureController(playerLayer: view.playerLayer)

    return view
  }

  static func dismantleUIView(_ uiView: LoopingPlayerUIView, coordinator: ()) {
    uiView.cleanup()
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

final class LoopingPlayerUIView: UIView {
  private var player: AVQueuePlayer?
  private var token: NSKeyValueObservation?

  private var allURLs: [URL]

  var playerLayer: AVPlayerLayer {
    // swiftlint:disable:next force_cast
    layer as! AVPlayerLayer
  }

  override class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }

  init(urls: [URL]) {
    allURLs = urls
    player = AVQueuePlayer()

    super.init(frame: .zero)

    addAllVideosToPlayer()

    playerLayer.player = player

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
      let asset = AVURLAsset(url: url)
      let item = AVPlayerItem(asset: asset)
      player?.insert(item, after: player?.items().last)
    }
  }

  func setVolume(_ value: Float) {
    player?.volume = value
  }

  func setRate(_ value: Float) {
    player?.rate = value
  }

  func cleanup() {
    player?.pause()
    player?.removeAllItems()
    player = nil
  }
}
