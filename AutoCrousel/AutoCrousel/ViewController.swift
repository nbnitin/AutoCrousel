//
//  ViewController.swift
//  AutoCrousel
//
//  Created by Nitin Bhatia on 26/12/22.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var crouselView: CrouselView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        crouselView.crouselImages = ["img1","img2","img3","img4"]
        crouselView.startProgress()
    }
    
}

