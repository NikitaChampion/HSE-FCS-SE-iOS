//
//  ViewController.swift
//  BlurApp
//
//  Created by Никита Игумнов on 31.01.2021.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var backgroundImageView: UIImageView!
    
    private let imageSet = ["london", "newyork", "paris", "rome", "sydney"]
    private var blurEffectView: UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedImageIndex = Int(arc4random_uniform(5))
        
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }
}

