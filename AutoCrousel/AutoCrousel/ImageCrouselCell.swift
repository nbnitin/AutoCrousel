//
//  ImageCrouselCell.swift
//  AutoCrousel
//
//  Created by Nitin Bhatia on 26/12/22.
//

import UIKit
import AVKit

class ImageCrouselCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCrousel: UIImageView!
}


class TextCrouselCell: UICollectionViewCell {
    
    @IBOutlet weak var lblSrc: UILabel!
}


protocol VideoCrouselCellProtocol {
    func didVideoStarted()
}

class VideoCrouselCell: UICollectionViewCell {
    var player : AVPlayer!
    var delegate : VideoCrouselCellProtocol!
    var playerLayer : AVPlayerLayer!
    
    func configure() {
        
        
        
        let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        player = AVPlayer(url: videoURL!)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.contentView.bounds
        contentView.layer.addSublayer(playerLayer)
        player.play()

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player.rate > 0 {
                print("video started")
                delegate.didVideoStarted()
            }
        }
    }
}
