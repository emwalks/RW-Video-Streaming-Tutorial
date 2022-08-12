# Video Streaming on iOS Tutorial

Follows progress on the RW tutorial [Video Streaming Tutorial for iOS](https://www.raywenderlich.com/22372639-video-streaming-tutorial-for-ios-getting-started)

Swift 5, iOS 15.4

Although SwiftUI contains the [VideoPlayer](https://developer.apple.com/documentation/avkit/videoplayer) view, which is created with a player (e.g. AVPlayer) it currently does not support Picture in Picture mode. At the time of writing to do this you can add a UIViewControllerRepresentable to bridge an AVPlayerViewController with a SwiftUI view. See [VideoPlayerView](https://github.com/emwalks/RW-Video-Streaming-Tutorial/blob/main/starter/TravelVlogs/Views/VideoPlayers/VideoPlayerView.swift) as an example in this repo. 

For the embedded playback view in this repo [LoopingPlayerView](https://github.com/emwalks/RW-Video-Streaming-Tutorial/blob/main/starter/TravelVlogs/Views/VideoPlayers/LoopingPlayerView.swift), an AVPlayerLayer was wrapped as a UIViewRepresentable to bridge into SwiftUI. 
An AVPlayerLAyer was needed to customise the view and also to add custom gestures. 


