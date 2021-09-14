//
//  LeaderBoardHeaderView.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/14/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class LeaderBoardHeaderView: UIView {
    
    private let nameHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Player Name"
        return label
    }()
    
    private let scoreHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Score"
        return label
    }()
    
    private let matchTimeHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Match Time"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemRed
        
        // add subviews
        addSubview(nameHeaderLabel)
        addSubview(scoreHeaderLabel)
        addSubview(matchTimeHeaderLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // assign frames
        nameHeaderLabel.frame = CGRect(x: 10, y: (frame.size.height/2)-((frame.size.width/3)/2), width: frame.size.width/3, height: frame.size.height/2)
        scoreHeaderLabel.frame = CGRect(x: nameHeaderLabel.frame.origin.x+nameHeaderLabel.frame.size.width+10, y: (frame.size.height/2)-((frame.size.width/3)/2), width: frame.size.width/3, height: frame.size.height/2)
        matchTimeHeaderLabel.frame = CGRect(x: scoreHeaderLabel.frame.origin.x+scoreHeaderLabel.frame.size.width+10, y: (frame.size.height/2)-((frame.size.width/3)/2), width: frame.size.width/3, height: frame.size.height/2)
    }
}
