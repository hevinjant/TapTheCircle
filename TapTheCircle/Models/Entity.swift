//
//  Entity.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation
import UIKit

class Entity {
    static let shared = Entity()

    func square(origin: CGPoint, color: UIColor, tag: Int) -> UIView {
        let square = UIView()
        square.backgroundColor = color
        square.frame = CGRect(origin: origin, size: CGSize(width: 50, height: 50))
        square.tag = tag
 
        return square
    }
    
    func circle(origin: CGPoint, color: UIColor, tag: Int) -> UIView {
        let circle = UIView()
        circle.backgroundColor = color
        circle.frame = CGRect(origin: origin, size: CGSize(width: 50, height: 50))
        circle.layer.cornerRadius = 25
        circle.tag = tag

        return circle
    }
}
