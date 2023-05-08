//
//  GameScene.swift
//  Project17.1
//
//  Created by Maks Vogtman on 16/12/2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let possibleEnemies = ["ball", "hammer", "tv"]
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var finalScore: SKLabelNode!
    var gameTimer: Timer?
    var isGameOver = false
    var isPlayerTouched: Bool!
    var timeInterval = 0.0
    
    var numberOfEnemies = 0 {
        didSet {
            if numberOfEnemies.isMultiple(of: 20) {
                timeInterval -= 0.1
                gameTimer?.invalidate()
                gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            }
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        timeInterval = 1.0
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        numberOfEnemies += 1
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.linearDamping = 0
        
        if isGameOver == true {
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 484)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            sprite.removeFromParent()
            showFinalScore()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node == player {
                isPlayerTouched = true
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlayerTouched == true {
            guard let touch = touches.first else { return }
            var location = touch.location(in: self)
            
            if location.y < 100 {
                location.y = 100
            } else if location.y > 668 {
                location.y = 668
            }
            
            player.position = location
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node == player {
                isPlayerTouched = false
            }
        }
    }
    
    
    func showFinalScore() {
        finalScore = SKLabelNode()
        finalScore.position = CGPoint(x: 512, y: 260)
        finalScore.text = "Final score: \(score)"
        finalScore.fontName = "AvenirNext-Bold"
        finalScore.horizontalAlignmentMode = .center
        finalScore.fontSize = 110
        finalScore.zPosition = 1
        addChild(finalScore)
    }
}
