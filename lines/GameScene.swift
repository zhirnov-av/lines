//
//  GameScene.swift
//  lines
//
//  Created by Andrei Zhirnov on 18/11/2018.
//  Copyright © 2018 Andrei Zhirnov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {



    private var lines : Lines?
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var scoreLabel : SKLabelNode?
    					
    func initScene() {
        lines = Lines.init(gameScene: self)
    }

    public func showGameOver() {
        label = scene!.childNode(withName: "//gameOver") as? SKLabelNode
        if let label = label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 1.0))
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 1.0
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.025
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        scoreLabel = SKLabelNode()
        scoreLabel!.alpha = 1.0
        scoreLabel!.fontSize = 40
        
        scoreLabel!.fontColor = SKColor.white
        scoreLabel!.position = CGPoint(x: 0, y: -150)

        self.addChild(self.scoreLabel!)
        
        initScene()
        
        print("didMove\n")
    }

    func updateScoreLabel() {
        
        self.scoreLabel!.text = "\(self.lines!.score)"
    }
    
    func touchDown(atPoint pos : CGPoint) {
        /*
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
         */
        lines!.tapMap(atPoint: pos)
        
        //scoreLabel!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.0),
                                         //  SKAction.removeFromParent()]))

        
        //self.addChild(self.scoreLabel!)


    }
    
    func touchMoved(toPoint pos : CGPoint) {

        /*
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
        */
        print("touchMoved\n")
    }
    
    func touchUp(atPoint pos : CGPoint) {
        /*
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
         */
        print("touchUp\n")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        */
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
