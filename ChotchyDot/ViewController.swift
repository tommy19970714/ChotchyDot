//
//  ViewController.swift
//  ChotchyDot
//
//  Created by 冨平準喜 on 2015/12/26.
//  Copyright © 2015年 冨平準喜. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene()
        
        let view = self.view as! SKView
        view.showsFPS = true
        view.showsNodeCount = true
        scene.size = view.frame.size
        
        view.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

