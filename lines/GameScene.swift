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

    enum fillResult {
        case ERROR
        case FOUND
        case DONE
    }

    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var elements = [SKShapeNode?]()
    private var w : CGFloat = 0
    private var selectedElement : SKShapeNode?
    private var map = [[Int]]()
    
    private let mapWidth = 10
    private let mapHeight = 10

    func toArrayCoord(pos : CGPoint) -> (x: Int, y: Int) {

        let dx : Double = Double((pos.x + self.size.width / 2 - w / 2 - 5) / w)
        let dy : Double = Double((pos.y - self.size.height / 2 + w / 2 + 5) / -w)

        print("Double: x = \(dx), y = \(dy)")
        print("Int: x = \(Int(dx)), y = \(Int(dy))")

        return ( Int( round(dx) ), Int( round(dy) ) )
    }

    func fillAround(point: (x: Int, y: Int), value: Int) -> fillResult {
        if point.y - 1 >= 0 && map[point.x][point.y-1] == 0 {
            map[point.x][point.y-1] = value
        } else if point.y - 1 >= 0 && map[point.x][point.y-1] == -2 {
            return fillResult.FOUND
        }
        if point.y + 1 < mapHeight && map[point.x][point.y + 1] == 0 {
            map[point.x][point.y + 1] = value
        } else if point.y + 1 < mapHeight && map[point.x][point.y + 1] == -2 {
            return fillResult.FOUND
        }
        if point.x - 1 >= 0 && map[point.x - 1][point.y] == 0 {
            map[point.x - 1][point.y] = value
        } else if point.x - 1 >= 0 && map[point.x - 1][point.y] == -2 {
            return fillResult.FOUND
        }
        if point.x + 1 < mapWidth && map[point.x + 1][point.y] == 0 {
            map[point.x + 1][point.y] = value
        } else if point.x + 1 < mapWidth && map[point.x + 1][point.y] == -2 {
            return fillResult.FOUND
        }
        var result : fillResult
        var flgDone: Bool = false
        if point.y - 1 >= 0 && map[point.x][point.y-1] == value {
            result = fillAround(point: (point.x, point.y - 1), value: value + 1)
            if result == fillResult.FOUND {
                return result
            }
            flgDone = ( result == fillResult.DONE ? true : flgDone )
        }
        if point.y + 1 < mapHeight && map[point.x][point.y + 1] == value {
            result = fillAround(point: (point.x, point.y + 1), value: value + 1)
            if result == fillResult.FOUND {
                return result
            }
            flgDone = ( result == fillResult.DONE ? true : flgDone )
        }
        if point.x - 1 >= 0 && map[point.x - 1][point.y] == value {
            result = fillAround(point: (point.x - 1, point.y), value: value + 1)
            if result == fillResult.FOUND {
                return result
            }
            flgDone = ( result == fillResult.DONE ? true : flgDone )
        }
        if point.x + 1 < mapWidth && map[point.x + 1][point.y] == value {
            result = fillAround(point: (point.x + 1, point.y), value: value + 1)
            if result == fillResult.FOUND {
                return result
            }
            flgDone = ( result == fillResult.DONE ? true : flgDone )
        }
        if flgDone {
            return fillResult.DONE
        }
        return fillResult.ERROR
    }

    func findWay(start: (x: Int, y: Int), end: (x: Int, y: Int)) -> [(x: Int, y: Int)] {
        var path = [(x: Int, y: Int)]()

        //var map = [[Int]]()
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                let index = y * self.mapWidth + x
                if (x == end.x && y == end.y) {
                    map[x][y] = -2
                    continue
                }
                map[x][y] = elements[index] === nil ? 0 : -5
            }
        }
        map[start.x][start.y] = -1
        let result = fillAround(point: (start.x, start.y), value: 1)
        print("findWay: \(result)")

        return path
    }

    func toSceneCoord(x: Int, y: Int) -> CGPoint {
        let xx: CGFloat = CGFloat(x)
        let yy: CGFloat = CGFloat(y)
        return CGPoint(x: CGFloat(w * xx) - self.size.width / 2 + w / 2 + 5, y:  ( -CGFloat( w * yy) + self.size.height / 2  - w / 2 - 5))
    }

    func addItemToMap(x: Int, y: Int, color: SKColor) {
        let n = SKShapeNode.init(rectOf: CGSize.init(width: w - 5, height: w - 5), cornerRadius: self.w * 0.3)
        n.lineWidth = 3
        n.position = toSceneCoord(x: x, y: y)
        n.strokeColor = color
        n.fillColor = color
        elements[y * mapWidth + x] = n;
        self.addChild(n)
    }

    func initScene() {
        self.w = (self.size.width - CGFloat(mapWidth)) / CGFloat(mapWidth)
        for _ in 0..<(mapWidth * mapHeight) {
            elements.append(nil)
        }

        for y in 0..<mapHeight {
            var row = [Int]()
            for x in 0..<mapWidth {
                row.append(0)
            }
            map.append(row)
        }
        
        let n = SKShapeNode.init(rectOf: CGSize.init(width: w * CGFloat(mapWidth), height: w * CGFloat(mapWidth)), cornerRadius: self.w * 0.3)
        n.lineWidth = 0.5
        n.position = CGPoint(x: 0, y: self.size.height / 4 - self.w / 2 - 5)
        n.strokeColor = SKColor.darkGray
        self.addChild(n)
    }

    func addRandomBall() {
        var availablePlaces = [Int]()
        var busyCount = 0
        for i in 0..<(mapWidth * mapHeight) {
            let y : Int = i / mapWidth
            let x : Int = i % mapWidth
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
        let y : Int = availablePlaces[index] / mapWidth
        let x : Int = availablePlaces[index] % mapWidth

        let iColor = Int.random(in: 0 ... 5)

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
        case    3 :
            self.addItemToMap(x: x, y: y, color: SKColor.cyan)
            break
        case    4 :
            self.addItemToMap(x: x, y: y, color: SKColor.yellow)
            break
        case    5 :
            self.addItemToMap(x: x, y: y, color: SKColor.orange)
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
        let w = (self.size.width + self.size.height) * 0.025
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        initScene()

        for _ in 1...20 {
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

        if elements[res.y * mapWidth + res.x] != nil {
            for i in 0..<(mapWidth * mapHeight) {
                if elements[i] != nil {
                    elements[i]!.removeAllActions()
                    elements[i]!.run(SKAction.rotate(toAngle: 0, duration: 0))
                    //elements[i]!.strokeColor = SKColor.white
                }
            }
        }
        
        let currAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1))
        if elements[res.y * mapWidth + res.x] != nil {
            elements[res.y * mapWidth + res.x]!.run(currAction, withKey: "ROTATION")
            self.selectedElement = elements[res.y * mapWidth + res.x]
        } else {
            if self.selectedElement != nil {


                let oldPos = selectedElement?.position
                let oldArrCoord = toArrayCoord(pos: oldPos!)

                findWay(start: toArrayCoord(pos: oldPos!), end: (x: res.x, y: res.y))

                let moving : SKAction = SKAction.move(to: toSceneCoord(x: res.x, y: res.y), duration: 0.5)
                self.selectedElement!.run(moving, completion: {
                    self.selectedElement!.removeAllActions()
                    self.selectedElement!.run(SKAction.rotate(toAngle: 0, duration: 0))

                    self.elements[res.y * self.mapWidth + res.x] = self.selectedElement
                    self.elements[oldArrCoord.y * self.mapWidth + oldArrCoord.x] = nil

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
