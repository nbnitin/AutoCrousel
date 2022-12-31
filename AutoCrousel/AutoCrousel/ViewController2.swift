//
//  ViewController2.swift
//  AutoCrousel
//
//  Created by Nitin Bhatia on 26/12/22.
//

import UIKit

enum CrouselType {
    case image
    case video
    case text
}

struct CrouselData {
    let crouselType : CrouselType?
    let crouselSrc : String?
    
    
    static func createData() -> [CrouselData] {
        var newData : [CrouselData] = [CrouselData]()
        for i in 1 ... 2 {
            let tempData = CrouselData(crouselType: .image, crouselSrc: "img\(i)")
            newData.append(tempData)
        }
        
        let tempData = CrouselData(crouselType: .video, crouselSrc: "Hello")
        newData.append(tempData)
        
        for i in 1 ... 1 {
            let tempData = CrouselData(crouselType: .text, crouselSrc: "Hello \(i)")
            newData.append(tempData)
        }
        
        return newData
    }
}

class ViewController2: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //outlets
    @IBOutlet var progressViews: [UIProgressView]!
    @IBOutlet weak var crouselCollView: UICollectionView!
    
    //variables
    var duration : Float = 5
    var progress : Float = 0.0
    var progressIndex : Int = 0
    var longPressGesture : UILongPressGestureRecognizer!
    var items : [CrouselData] = [CrouselData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startProgress()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(toggleAnimation(_:)))
        longPressGesture.minimumPressDuration = 0
       // view.addGestureRecognizer(longPressGesture)
        //crouselCollView.isUserInteractionEnabled = true
        items = CrouselData.createData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let crouselType = items[indexPath.row].crouselType, crouselType == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCrouselCell
            cell.imgCrousel.image = UIImage(named: items[indexPath.row].crouselSrc ?? "")
            return cell
        } else if let crouselType = items[indexPath.row].crouselType, crouselType == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCrouselCell
            cell.delegate = self
            cell.configure()
            longPressGesture.state = .began
            toggleAnimation(longPressGesture)
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCrouselCell
        cell.lblSrc.text = items[indexPath.row].crouselSrc ?? ""
        
        cell.addGestureRecognizer(longPressGesture)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoCrouselCell {
            videoCell.player.pause()
            videoCell.playerLayer.removeFromSuperlayer()
        }
    }
   
    //MARK: pauses / resumes animations
    @objc private func toggleAnimation(_ sender: UILongPressGestureRecognizer) {
        print(sender.state.rawValue)
        
        if sender.state == .possible || sender.state == .began || sender.state == .changed {
            //pause or stop animation
            UIView.animate(withDuration: 0, animations: {
                self.progressViews[self.progressIndex].setProgress(self.progress / self.duration, animated: true)
            })
        } else {
            startProgress()
        }
    }
    
    //MARK: start progress
    private func startProgress() {
        progress += 0.1
        
        if items.count > 0 && items[self.progressIndex].crouselType == .video {
            duration = 30
        } else {
            duration = 5
        }
        UIView.animate(withDuration: 0, delay: 0, options: [.curveEaseInOut], animations: {
            self.progressViews[self.progressIndex].setProgress(self.progress / self.duration, animated: true)
        }, completion: {_ in
            if self.longPressGesture?.state == .cancelled || self.longPressGesture.state == .possible {
                if self.progressViews[self.progressIndex].progress >= 1.0 {
                    self.didProgressFinished()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.startProgress()
                    })
                    
                }
            }
        })
    }
    
    //MARK: restart progress and reset other things which supports animation once one round of animation finishes
    private func didProgressFinished(_ shouldScroll : Bool = true) {
        
        progressViews[progressIndex].progress = 0
        progressIndex += 1
        
        if progressIndex >= progressViews.count {
            progressIndex = 0
            for case let (index, item) in progressViews.enumerated() {
                print(index)
                item.progress = 0
            }
        }
        if shouldScroll {
            crouselCollView.isPagingEnabled = false
            UIView.transition(with: crouselCollView, duration: 0.6 ,options: .transitionCrossDissolve ,animations: {
                self.crouselCollView.scrollToItem(at: IndexPath(row: self.progressIndex, section: 0), at: .centeredHorizontally, animated: true)
                self.crouselCollView.isPagingEnabled = true
            })
        }
        progress = 0.0
        startProgress()
    }
    
   
}

extension ViewController2 : VideoCrouselCellProtocol {
    func didVideoStarted() {
        longPressGesture.state = .ended
        self.startProgress()
    }
}
