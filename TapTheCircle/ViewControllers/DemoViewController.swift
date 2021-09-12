//
//  DemoViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

        let createButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .systemGreen
            button.setTitle("Create Square", for: .normal)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        
        let removeButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .systemOrange
            button.setTitle("Remove Square", for: .normal)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
            title = "Tap the Circle!"
            
            view.backgroundColor = .systemBlue
            
            // add subviews
            view.addSubview(createButton)
            view.addSubview(removeButton)
            
            createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
            removeButton.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // assign frames
            createButton.frame = CGRect(x: view.center.x-100, y: view.center.y, width: 200, height: 40)
            removeButton.frame = CGRect(x: view.center.x-100, y: createButton.frame.origin.y+50, width: 200, height: 40)
        }

        @objc private func didTapCreate() {
            var count = 0
            var yPos: CGFloat = 50
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
                count += 1
                print("square count: \(count)")
                if count >= 5 {
                    t.invalidate()
                }
                
    //            let square = UIView()
    //            square.backgroundColor = .red
    //            square.frame = CGRect(x: 50, y: yPos, width: 50, height: 50)
    //            square.tag = 1
                
                let entity: UIView
                if count % 2 == 0 {
                    entity = Entity.shared.square(origin: CGPoint(x: 50, y: 50), color: .systemRed, tag: 1)
                }
                else {
                    entity = Entity.shared.circle(origin: CGPoint(x: 50, y: 50), color: .systemRed, tag: 1)
                }
                
                DispatchQueue.main.async {
                    self.view.addSubview(entity)
                    yPos += 70
                }
            }
            timer.fire()
        }
        
        @objc private func didTapRemove() {
            if let square = self.view.viewWithTag(1) {
                square.removeFromSuperview()
            }
            else{
                print("Failed To Remove: No UIView found..")
            }
        }
}
