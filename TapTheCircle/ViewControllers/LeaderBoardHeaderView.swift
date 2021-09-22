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
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let scoreHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Score"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let matchTimeHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Match Time"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemBackground
        
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
        nameHeaderLabel.frame = CGRect(x: 15, y: 0, width: width/3, height: height)
        scoreHeaderLabel.frame = CGRect(x: nameHeaderLabel.right+10, y: 0, width: width/5, height: height)
        matchTimeHeaderLabel.frame = CGRect(x: scoreHeaderLabel.right+20, y: 0, width: width/2, height: height)
    }
}
