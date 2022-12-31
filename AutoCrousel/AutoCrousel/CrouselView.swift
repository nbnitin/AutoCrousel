//
//  CrouselView.swift
//  AutoCrousel
//
//  Created by Nitin Bhatia on 27/12/22.
//

import UIKit

class CrouselView: UIView, UIGestureRecognizerDelegate {

    //outlets
    @IBOutlet weak var imgCrousel: UIImageView!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnLeft: UIButton!
    
    @IBOutlet weak var btnRight: UIButton!
    //variables
    var duration : Float = 5
    var progress : Float = 0.0
    var progressIndex : Int = 0
    var longPressGesture : UILongPressGestureRecognizer!
    var tapGesture : UITapGestureRecognizer!
    var progressViews : [UIProgressView] = [UIProgressView]()
    var work : DispatchWorkItem!
    
    @IBInspectable
    var enableSingleClicks : Bool = false {
        didSet {
            tapGesture.isEnabled = enableSingleClicks
        }
    }
    
    var crouselImages : [String] = [String]() {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    var progressBarTintColor : UIColor? {
        didSet {
            progressViews.forEach({
                $0.tintColor = progressBarTintColor
            })
        }
    }
    
    @IBInspectable
    var progressBarTrackColor : UIColor? {
        didSet {
            progressViews.forEach({
                $0.trackTintColor = progressBarTrackColor
            })
        }
    }
    
    @IBInspectable
    var progresBarSpacing : CGFloat = 5 {
        didSet {
            progressStackView.spacing = progresBarSpacing
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func setupView() {
        for _ in 0 ... crouselImages.count - 1 {
            let progressView = UIProgressView()
            progressViews.append(progressView)
            progressStackView.addArrangedSubview(progressView)
            
            if let progressBarTrackColor {
                progressView.trackTintColor = progressBarTrackColor
            }
            
            if let progressBarTintColor {
                progressView.tintColor = progressBarTintColor
            }
        }
        imgCrousel.image = UIImage(named: crouselImages.first ?? "")
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("CrouselView", owner: self)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        //setting progresses, and long press gesture
       // startProgress()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(toggleAnimation(_:)))
        longPressGesture.minimumPressDuration = 0
        longPressGesture.delegate = self
        imgCrousel.addGestureRecognizer(longPressGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPerformed(_:)))
        tapGesture.delegate = self
        tapGesture.isEnabled = enableSingleClicks
        imgCrousel.addGestureRecognizer(tapGesture)
        imgCrousel.isUserInteractionEnabled = true
        work = DispatchWorkItem(block: {
            self.startProgress()
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc private func tapPerformed(_ sender: UITapGestureRecognizer) {
        
        if sender.location(in: imgCrousel).x <= frame.width / 2 {
            print("left side pressed")
            goToPrevious()
        } else {
            print("right side pressed")
            goToNext()
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
            work.cancel()
            work = DispatchWorkItem(block: {
                self.startProgress()
            })
            startProgress()
        }
    }

    //MARK: start progress
    func startProgress() {
        progress += 0.1
        
        UIView.animate(withDuration: 0.0, delay: 0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
            self.progressViews[self.progressIndex].setProgress(self.progress / self.duration, animated: true)
        }, completion: {_ in
            if self.longPressGesture?.state == .cancelled || self.longPressGesture.state == .possible {
                if self.progressViews[self.progressIndex].progress >= 1.0 {
                    self.progressViews[self.progressIndex].setProgress(1, animated: false)
                    self.progressIndex += 1
                    self.didProgressFinished()
                } else {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: self.work)
                }
            }
        })
    }
    
    //MARK: restart progress and reset other things which supports animation once one round of animation finishes
    private func didProgressFinished() {
        
        if progressIndex >= progressViews.count {
            progressIndex = 0
            for case let (index, item) in progressViews.enumerated() {
                print(index)
                item.progress = 0
            }
        }
        
        if crouselImages.count == 1 {
            return
        }
        
        UIView.transition(with: imgCrousel, duration: 0.6 ,options: .transitionCrossDissolve ,animations: {
            self.imgCrousel.image = UIImage(named: "img\(self.progressIndex + 1)")
        })
        progress = 0.0
        self.progressViews[self.progressIndex].setProgress(0, animated: false)
        startProgress()
    }
    
    
   private func goToPrevious() {
        if progressIndex == 0 {
            return
        }
        progressViews[progressIndex].setProgress(0, animated: false)

        progressIndex -= 1
        work.cancel()
        work = DispatchWorkItem(block: {
            self.startProgress()
        })
        didProgressFinished()
    }
    
    private func goToNext() {
        progressViews[progressIndex].setProgress(1, animated: false)

        progressIndex += 1
        layer.removeAllAnimations()
        work.cancel()
        work = DispatchWorkItem(block: {
            self.startProgress()
        })
        didProgressFinished()
    }
}
