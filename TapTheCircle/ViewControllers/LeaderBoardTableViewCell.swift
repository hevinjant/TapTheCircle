//
//  LeaderBoardTableViewCell.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/14/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {
    
    static let identifier = "LeaderBoardTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private let matchTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.clipsToBounds = true
        
        // add subviews
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(matchTimeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // assign frames
        nameLabel.frame = CGRect(x: separatorInset.left, y: contentView.center.y-((contentView.height/3)/2), width: contentView.width/3, height: contentView.height/3)
        scoreLabel.frame = CGRect(x: nameLabel.right+10, y: contentView.center.y-((contentView.height/3)/2), width: contentView.width/5, height: contentView.height/3)
        matchTimeLabel.frame = CGRect(x: scoreLabel.right+20, y: contentView.center.y-((contentView.frame.size.height/3)/2), width: contentView.width/3, height: contentView.height/3)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        scoreLabel.text = nil
        matchTimeLabel.text = nil
    }
    
    func configure(with model: UserLog) {
        nameLabel.text = model.name
        scoreLabel.text = String(model.score)
        matchTimeLabel.text = "\(model.matchTime)s"
    }
}
