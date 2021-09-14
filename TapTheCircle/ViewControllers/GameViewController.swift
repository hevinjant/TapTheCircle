//
//  GameViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var existingOrigins: [CGPoint] = []
    var viewQueue = QueueArray<UIView>()
    var gameIsRunning = false
    var score = 0
    let matchTime = 10
    
    let startGameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Start Game", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemOrange
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    let testView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Score: 0"
        return label
    }()
    
    let gameHasFinishedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Time is up!"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Tap the Circle!"
        
        view.backgroundColor = .systemBlue
        
        // add subviews
        view.addSubview(startGameButton)
        view.addSubview(backButton)
        view.addSubview(timerLabel)
        view.addSubview(scoreLabel)
        view.addSubview(gameHasFinishedLabel)
        
        startGameButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // assign frames
        startGameButton.frame = CGRect(x: view.frame.origin.x+20, y: view.frame.origin.y+view.frame.size.height-40-20, width: 130, height: 40)
        backButton.frame = CGRect(x: view.frame.origin.x+view.frame.size.width-80-20, y: view.frame.origin.y+view.frame.size.height-40-20, width: 80, height: 40)
        timerLabel.frame = CGRect(x: view.frame.origin.x+view.frame.size.width-90, y: view.frame.origin.y+20, width: 80, height: 40)
        scoreLabel.frame = CGRect(x: view.frame.origin.x+20, y: view.frame.origin.y+20, width: 100, height: 40)
        gameHasFinishedLabel.frame = CGRect(x: view.center.x-100, y: view.center.y, width: 200, height: 40)
    }
    
    @objc private func didTapStart() {
        startGameButton.isHidden = true
        backButton.isHidden = true
        gameHasFinishedLabel.isHidden = true
        startGame(withTimeInSeconds: matchTime)
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapEntity(_ sender: UITapGestureRecognizer) {
        guard let viewTag = sender.view?.tag else {
            print("View Tag not found.")
            return
        }
        userDidRemoveEntity(withViewTag: viewTag)
    }
    
    /// Record the match and put it into database after the game has finished.
    private func recordUserLog(userName: String, userEmail: String, score: Int, matchTime: Int) {
        let userLog = UserLog(id: UUID().uuidString, name: userName, email: userName, score: score, matchTime: matchTime, timeStamp: Date().timeIntervalSince1970)
    }
    
    private func printAllExistingOrigins() {
        print("Existing origin: ")
        for origin in self.existingOrigins {
            print(origin)
        }
        print("-----------------")
    }
}

// MARK: - Game logics
extension GameViewController {
    /// Start the game.
    private func startGame(withTimeInSeconds: Int) {
        gameIsRunning = true
        
        // get the points of the view
        let viewYPos = view.frame.origin.y
        let viewHeight = view.frame.size.height
        let viewXPos = view.frame.origin.x
        let viewWidth = view.frame.width
        
        // create game timer
        createGameTimer(withTimeInSeconds: withTimeInSeconds)
        
        // create new entity every 2 seconds
        var count = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] t in
            count += 1
            if !(self!.gameIsRunning) {
                t.invalidate()
                self?.gameHasFinished()
            }
            
            // initialize a new origin for entity
            let entity: UIView
            var ranX = CGFloat.random(in: viewXPos...viewXPos+viewWidth-50)
            var ranY = CGFloat.random(in: viewYPos+40...viewYPos+viewHeight-50)
            var newOrigin = CGPoint(x: Int(ranX),y: Int(ranY))
            
            // check if the new origin is conflicting, if it is then create a new origin
            while( self?.positionIsConflicting(for: newOrigin, existingOrigins: self!.existingOrigins, entitySize: 50) == 1 ) {
                ranX = CGFloat.random(in: viewXPos...viewXPos+viewWidth-50)
                ranY = CGFloat.random(in: viewYPos+40...viewYPos+viewHeight-50)
                newOrigin = CGPoint(x: Int(ranX),y: Int(ranY))
            }
            
            // create a new entity with the new origin
            entity = Entity.shared.circle(origin: newOrigin, color: .systemRed, tag: count)
            entity.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self?.didTapEntity(_:)))
            tap.numberOfTapsRequired = 1
            entity.addGestureRecognizer(tap)
            
            // add the entity to the view
            DispatchQueue.main.async {
                self?.view.addSubview(entity)
                self?.existingOrigins.append(newOrigin)
                self?.viewQueue.enQueue(item: entity)
                //print("+ a new entity has been added to the view.")
            }
        }
        timer.fire()
        startRemovingEntity()
    }
    
    /// Removes the entities according to their created order.
    private func startRemovingEntity() {
        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] t in
            guard let queueIsEmpty = self?.viewQueue.isEmpty() else {
                return
            }
            if !(self!.gameIsRunning) && queueIsEmpty {
                t.invalidate()
            }
            guard let entity = self?.viewQueue.deQueue() else {
                return
            }
            entity.removeFromSuperview()
            //print("- an entity has been removed from the view.")
        })
        timer.fire()
    }
    
    /// Removes an entity that the user tapped.
    private func userDidRemoveEntity(withViewTag: Int) {
        if let entity = self.view.viewWithTag(withViewTag) {
            // remove the view's origin from the array
            print("square origin: \(entity.frame.origin)")
            let removedPoint = CGPoint(x: entity.frame.origin.x, y: entity.frame.origin.y)
            for i in 0..<self.existingOrigins.count {
                if removedPoint.x == self.existingOrigins[i].x && removedPoint.y == self.existingOrigins[i].y {
                    self.existingOrigins.remove(at: i)
                    //print("- user has removed an entity.")
                    break
                }
            }
            // remove the square from the view
            entity.removeFromSuperview()
            if gameIsRunning {
                score += 1
            }
            scoreLabel.text = "Score: \(score)"
            
        }
        else{
            print("Failed To Remove: No UIView found..")
        }
    }
    
    /// Returns 1 if the new entity conflicts with other existing entity by checking their origins, returns 0 otherwise.
    private func positionIsConflicting(for newOrigin: CGPoint, existingOrigins: [CGPoint], entitySize: CGFloat) -> Int {
        var isConflicting = 0
        
        for origin in existingOrigins {
            if (newOrigin.x >= origin.x && newOrigin.x <= origin.x + entitySize) ||
                (newOrigin.y >= origin.y && newOrigin.y <= origin.y + entitySize) {
                isConflicting = 1
            }
        }
        
        return isConflicting
    }
    
    /// Create and fire the game timer.
    private func createGameTimer(withTimeInSeconds: Int) {
        var timeLeft = withTimeInSeconds
        let gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] t in
            if timeLeft <= 0 {
                self?.gameIsRunning = false
                t.invalidate()
            }
            DispatchQueue.main.async {
                self?.timerLabel.text = "Time: \(timeLeft)"
                timeLeft -= 1
            }
        })
        gameTimer.fire()
    }
    
    /// Cleans up all the unremoved entities.
    private func gameHasFinished() {
        while !(viewQueue.isEmpty()) {
            if let entity = viewQueue.deQueue() {
                entity.removeFromSuperview()
            }
        }
        startGameButton.isHidden = false
        backButton.isHidden = false
        gameHasFinishedLabel.isHidden = false
        
        guard let email = UserDefaults.standard.string(forKey: "email"),
            let name = UserDefaults.standard.string(forKey: "name") else {
                return
        }
        
        let userLog = UserLog(id: UUID().uuidString, name: name, email: email, score: score, matchTime: matchTime, timeStamp: Date().timeIntervalSince1970)
        
        DatabaseManager.shared.insertUserLog(userLog: userLog, completion: { success in
            guard success else {
                return
            }
            print("Success inserting userlog to database")
        })
    }
}
