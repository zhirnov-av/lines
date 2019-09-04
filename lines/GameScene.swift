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
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var elements = [SKShapeNode?]()
    private var w : CGFloat = 0
    private var selectedElement : SKShapeNode?

    func toArrayCoord(pos : CGPoint) -> (x: Int, y: Int) {
        return ( Int( ( pos.x - 100 + w / 2 + self.size.width / 2 ) / 110 ), Int( ( pos.y + 100 - w / 2 - self.size.height / 2 ) / -110 ) )
    }

    func toSceneCoord(x: Int, y: Int) -> CGPoint {
        let xx: Double = Double(x)
        let yy: Double = Double(y)
        return CGPoint(x: CGFloat(110.0 * xx) - self.size.width / 2 + 100, y: CGFloat( -110.0 * yy)  + self.size.height / 2 - 100 )
    }

    func addItemToMap(x: Int, y: Int, color: SKColor) {
        let n = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: self.w * 0.3)
        n.lineWidth = 2.5
        n.position = toSceneCoord(x: x, y: y)
        n.strokeColor = color
        elements[y * 5 + x] = n;
        self.addChild(n)
    }

    func initScene() {
        self.w = (self.size.width + self.size.height) * 0.05
        for _ in 0...24 {
            elements.append(nil)
        }
    }

    func addRandomBall() {
        var availablePlaces = [Int?]()
        for i in 0...24 {
            if elements[i] === nil {
                availablePlaces.append(i)
            }
        }

        if availablePlaces.count == 0 {
            self.label = self.childNode(withName: "//gameOver") as? SKLabelNode
            if let label = self.label {
                label.alpha = 0.0
                label.run(SKAction.fadeIn(withDuration: 1.0))
            }
            return
        }


        let index = Int.random(in: 0 ..< availablePlaces.count)
        let y : Int = index / 5
        let x : Int = index % 5

        let iColor = Int.random(in: 0 ... 2)

        switch iColor {
        case    0 :
            self.addItemToMap(x: x, y: y, color: SKColor.blue)
            break
        case    1 :
            self.addItemToMap(x: x, y: y, color: SKColor.green)
            break
        case    2 :
            self.addItemToMap(x: x, y: y, color: SKColor.red)
            break
        default :
            self.addItemToMap(x: x, y: y, color: SKColor.blue)
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
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        initScene()

        for _ in 1...3 {
            addRandomBall()
        }
        //addItemToMap(x: 1, y: 1, color: SKColor.blue)
        //addItemToMap(x: 3, y: 4, color: SKColor.green)
        
        print("didMove\n")
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        /*
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
         */
        print("touchDown x = \(pos.x) y = \(pos.y)\n")
        let res = toArrayCoord(pos: pos)
        print("array x = \(res.x) y = \(res.y)\n")

        if elements[res.y * 5 + res.x] != nil {
            for i in 0...24 {
                if elements[i] != nil {
                    elements[i]!.removeAllActions()
                    elements[i]!.run(SKAction.rotate(toAngle: 0, duration: 0))
                    //elements[i]!.strokeColor = SKColor.white
                }
            }
        }
        
        let currAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1))
        if elements[res.y * 5 + res.x] != nil {
            elements[res.y * 5 + res.x]!.run(currAction, withKey: "ROTATION")
            self.selectedElement = elements[res.y * 5 + res.x]
        } else {
            if self.selectedElement != nil {
                let oldPos = selectedElement?.position
                let oldArrCoord = toArrayCoord(pos: oldPos!)

                let moving : SKAction = SKAction.move(to: toSceneCoord(x: res.x, y: res.y), duration: 0.5)
                self.selectedElement!.run(moving, completion: {
                    self.selectedElement!.removeAllActions()
                    self.selectedElement!.run(SKAction.rotate(toAngle: 0, duration: 0))

                    self.elements[res.y * 5 + res.x] = self.selectedElement
                    self.elements[oldArrCoord.y * 5 + oldArrCoord.x] = nil

                    self.selectedElement = nil

                    for _ in 1...3 {
                        self.addRandomBall()
                    }

                })
            }
        }

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
