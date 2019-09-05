//
//  lines.swift
//  lines
//
//  Created by Andrei Zhirnov on 05/09/2019.
//  Copyright © 2019 Andrei Zhirnov. All rights reserved.
//

import Foundation
import SpriteKit

class Lines {
    
    public var w : CGFloat = 0
    public let mapWidth = 9
    public let mapHeight = 9
    public var score : Int = 0
    
    private let MIN_LINE_SIZE = 5
    
    private var scene: GameScene?
    private var map = [[Int]]()
    private var elements = [SKShapeNode?]()
    private var selectedElement : SKShapeNode?
    
    private var canSelect = true

    private var nextColors = [SKShapeNode?]()
    
    init(gameScene: GameScene) {
        self.scene = gameScene
        self.w = (scene!.size.width - CGFloat(mapWidth)) / CGFloat(mapWidth)
        
        for _ in 0..<(mapWidth * mapHeight) {
            elements.append(nil)
        }

        for i in 0 ..< 3 {
            nextColors.append(SKShapeNode.init(rectOf: CGSize.init(width: w - 5, height: w - 5), cornerRadius: self.w * 0.3))
            let x: CGFloat = CGFloat( 0 - CGFloat(w * 3 / 2) + CGFloat(i) * w  + w / 2)
            let y: CGFloat = CGFloat( self.scene!.size.height / 2 - w * CGFloat(mapHeight) - CGFloat(w * 2))
            nextColors[i]?.position = CGPoint(x: x, y: y)
            let color = getRandomColor()
            nextColors[i]?.strokeColor = color
            nextColors[i]?.fillColor = color
            scene!.addChild(nextColors[i]!)
        }
        
        for _ in 0..<mapHeight {
            var row = [Int]()
            for _ in 0..<mapWidth {
                row.append(0)
            }
            map.append(row)
        }

        /*
        let n = SKShapeNode.init(rectOf: CGSize.init(width: w * CGFloat(mapWidth), height: w * CGFloat(mapWidth)), cornerRadius: w * 0.3)
        n.lineWidth = 0.5
        n.position = CGPoint(x: 0, y: scene!.size.height / 4 - w / 2 - 5)
        n.strokeColor = SKColor.darkGray
        scene!.addChild(n)
        */

        let blockSize : CGFloat = self.w
        if let grid = Grid(blockSize: blockSize, rows: mapHeight, cols: mapWidth) {
            grid.position = CGPoint (x: scene!.frame.midX, y: scene!.size.height / 4 - self.w / 2 - 2.5)
            scene!.addChild(grid)
        }
        
        for i in 0 ..< 3 {
            let pos = addRandomBall(ind: i)
            if pos != nil {
                score += self.checkAndRemove(res: pos!, auto: true)
            }
        }
    }
    
    func toArrayCoord(pos : CGPoint) -> (x: Int, y: Int) {
        
        let dx : Double = Double((pos.x + scene!.size.width / 2 - w / 2 - 5) / w)
        let dy : Double = Double((pos.y - scene!.size.height / 2 + w / 2 + 5) / -w)
        
        print("Double: x = \(dx), y = \(dy)")
        print("Int: x = \(Int(dx)), y = \(Int(dy))")
        
        return ( Int( round(dx) ), Int( round(dy) ) )
    }
    
    func toSceneCoord(x: Int, y: Int) -> CGPoint {
        let xx: CGFloat = CGFloat(x)
        let yy: CGFloat = CGFloat(y)
        return CGPoint(x: CGFloat(w * xx) - scene!.size.width / 2 + w / 2 + 5, y:  ( -CGFloat( w * yy) + scene!.size.height / 2  - w / 2 - 5))
    }
    

    func fillAroundV2(point: (x: Int, y: Int), value: Int) -> FillResult {
        var bFilled = false
        if point.y - 1 >= 0 && map[point.x][point.y-1] == -1 {
            map[point.x][point.y-1] = value
            bFilled = true
        } else if point.y - 1 >= 0 && map[point.x][point.y-1] == -3 {
            return FillResult.FOUND
        }
        if point.y + 1 < mapHeight && map[point.x][point.y + 1] == -1 {
            map[point.x][point.y + 1] = value
            bFilled = true
        } else if point.y + 1 < mapHeight && map[point.x][point.y + 1] == -3 {
            return FillResult.FOUND
        }
        if point.x - 1 >= 0 && map[point.x - 1][point.y] == -1 {
            map[point.x - 1][point.y] = value
            bFilled = true
        } else if point.x - 1 >= 0 && map[point.x - 1][point.y] == -3 {
            return FillResult.FOUND
        }
        if point.x + 1 < mapWidth && map[point.x + 1][point.y] == -1 {
            map[point.x + 1][point.y] = value
            bFilled = true
        } else if point.x + 1 < mapWidth && map[point.x + 1][point.y] == -3 {
            return FillResult.FOUND
        }
        if bFilled { return FillResult.DONE } else { return FillResult.ERROR }
    }
    
    func fillMap(level: Int) -> FillResult {
        var bFilled = false
        for y in 0 ..< mapHeight {
            for x in 0 ..< mapWidth {
                if map[x][y] == level - 1 {
                    let result = fillAroundV2(point: (x: x, y: y), value: level)
                    if result == FillResult.FOUND {
                        return result
                    } else if result == FillResult.DONE {
                        bFilled = true
                    }
                }
                
            }
        }
        if bFilled {
            return fillMap(level: level + 1)
        }
        
        return FillResult.ERROR
    }
    
    func findWay(start: (x: Int, y: Int), end: (x: Int, y: Int)) -> [(x: Int, y: Int)] {
        var path = [(x: Int, y: Int)]()
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                let index = y * self.mapWidth + x
                if (x == end.x && y == end.y) {
                    map[x][y] = -3
                    continue
                }
                map[x][y] = elements[index] === nil ? -1 : -5
            }
        }
        map[start.x][start.y] = 0
        let result = fillMap(level: 1)
        
        if result == FillResult.FOUND {
            var point = end
            path.append(point)
            while !(point.x == start.x && point.y == start.y) {
                point = findClosestMin(p: point)
                path.append(point)
            }
            path.remove(at: path.count - 1)
            path.reverse()
        }
        
        print("findWay: \(result)")
        print("path: \(path)")
        
        return path
    }
    
    func findClosestMin(p: (x: Int, y: Int)) -> (x: Int, y: Int) {
        var min = 100
        var pMin = p
        if p.y-1 >= 0 && map[p.x][p.y-1] >= 0 && map[p.x][p.y-1] < min {
            min = map[p.x][p.y-1]
            pMin = (p.x, p.y-1)
        }
        if p.y+1 < mapHeight && map[p.x][p.y+1] >= 0 && map[p.x][p.y+1] < min {
            min = map[p.x][p.y+1]
            pMin = (p.x, p.y+1)
        }
        if p.x-1 >= 0 && map[p.x-1][p.y] >= 0 && map[p.x-1][p.y] < min {
            min = map[p.x-1][p.y]
            pMin = (p.x-1, p.y)
        }
        if p.x+1 < mapWidth && map[p.x+1][p.y] >= 0 && map[p.x+1][p.y] < min {
            min = map[p.x+1][p.y]
            pMin = (p.x+1, p.y)
        }
        return pMin
    }

    func addItemToMap(x: Int, y: Int, color: SKColor) {
        let n = SKShapeNode.init(rectOf: CGSize.init(width: w - 5, height: w - 5), cornerRadius: self.w * 0.3)
        n.lineWidth = 3
        n.position = toSceneCoord(x: x, y: y)
        n.strokeColor = color
        n.fillColor = color
        elements[y * mapWidth + x] = n;
        scene!.addChild(n)
    }

    func getRandomColor() -> SKColor {
        let iColor = Int.random(in: 0 ... 5)

        switch iColor {
        case    0 :
            return SKColor.blue
        case    1 :
            return SKColor.green
        case    2 :
            return SKColor.red
        case    3 :
            return SKColor.cyan
        case    4 :
            return SKColor.yellow
        case    5 :
            return SKColor.orange
        default :
            return SKColor.blue
        }
    }

    func addRandomBall( ind: Int ) -> (x: Int, y: Int)? {
        var availablePlaces = [Int]()
        for i in 0..<(mapWidth * mapHeight) {
            if elements[i] === nil {
                availablePlaces.append(i)
            }
        }
        
        if availablePlaces.count == 0 {
            scene!.showGameOver()
            return nil
        }
        
        let index = Int.random(in: 0 ..< availablePlaces.count)
        let y : Int = availablePlaces[index] / mapWidth
        let x : Int = availablePlaces[index] % mapWidth
        
        self.addItemToMap(x: x, y: y, color: nextColors[ind]!.fillColor)
        nextColors[ind]!.fillColor = getRandomColor()

        return (x: x, y: y)
    }
    
    func checkAndRemove(res: (x: Int, y: Int), auto : Bool = false) -> Int {
        var line = self.checkLine(p: res, d: (0, -1))
        if line.count > 0 {
            for i in 0..<line.count {
                self.elements[line[i]]!.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2)))
                self.elements[line[i]]!.run(SKAction.scale(to: 0, duration: 0.3))
                self.elements[line[i]]!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                                               SKAction.removeFromParent()]))
                self.elements[line[i]] = nil
            }
            return line.count
        }
        
        line = self.checkLine(p: res, d: (-1, -1))
        if line.count > 0 {
            for i in 0..<line.count {
                self.elements[line[i]]!.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2)))
                self.elements[line[i]]!.run(SKAction.scale(to: 0, duration: 0.3))
                self.elements[line[i]]!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                                               SKAction.removeFromParent()]))
                self.elements[line[i]] = nil
            }
            return line.count
        }
        
        line = self.checkLine(p: res, d: (-1, 0))
        if line.count > 0 {
            for i in 0..<line.count {
                self.elements[line[i]]!.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2)))
                self.elements[line[i]]!.run(SKAction.scale(to: 0, duration: 0.3))
                self.elements[line[i]]!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                                               SKAction.removeFromParent()]))
                self.elements[line[i]] = nil
            }
            return line.count
        }
        
        line = self.checkLine(p: res, d: (-1, 1))
        if line.count > 0 {
            for i in 0..<line.count {
                self.elements[line[i]]!.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2)))
                self.elements[line[i]]!.run(SKAction.scale(to: 0, duration: 0.3))
                self.elements[line[i]]!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                                               SKAction.removeFromParent()]))
                self.elements[line[i]] = nil
            }
            return line.count
        }

        if auto { return 0 }
        return 1
    }
    
    func checkLine(p: (x: Int, y: Int), d: (x: Int, y: Int)) -> [Int] {
        var line = [p.y * mapWidth + p.x]
        var x : Int = p.x
        var y : Int = p.y
        
        var dx : Int = d.x
        var dy : Int = d.y
        
        var count : Int = 1
        let color : SKColor = elements[y * mapWidth + x]!.fillColor
        
        
        while x + dx >= 0 && x + dx < mapWidth && y + dy >= 0 && y + dy < mapHeight && elements[(y + dy) * mapWidth + x + dx]?.fillColor == color {
            count += 1
            x += dx
            y += dy
            line.append(y * mapWidth + x)
        }
        
        dx *= -1
        dy *= -1
        
        x = p.x
        y = p.y
        
        while x + dx >= 0 && x + dx < mapWidth && y + dy >= 0 && y + dy < mapHeight && elements[(y + dy) * mapWidth + x + dx]?.fillColor == color {
            count += 1
            x += dx
            y += dy
            line.append(y * mapWidth + x)
        }
        if count >= MIN_LINE_SIZE { return line }
        return []
    }
    
    public func tapMap(atPoint pos : CGPoint) {
        if !canSelect { return }
        
        print("touchDown x = \(pos.x) y = \(pos.y)\n")
        let res = toArrayCoord(pos: pos)
        print("array x = \(res.x) y = \(res.y)\n")
        
        if res.y < 0 || res.y >= mapHeight || res.x < 0 || res.x >= mapWidth {
            return
        }
        
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
                
                let path = findWay(start: toArrayCoord(pos: oldPos!), end: (x: res.x, y: res.y))
                
                if path.count > 0 {
                    self.canSelect = false
                    var seq = [SKAction]()
                    for i in 0..<path.count {
                        seq.append(SKAction.move(to: toSceneCoord(x: path[i].x, y: path[i].y), duration: 0.1))
                    }
                    let moving : SKAction = SKAction.sequence(seq)
                    self.selectedElement!.run(moving, completion: {
                        
                        self.selectedElement!.removeAllActions()
                        self.selectedElement!.run(SKAction.rotate(toAngle: 0, duration: 0))
                        
                        self.elements[res.y * self.mapWidth + res.x] = self.selectedElement
                        self.elements[oldArrCoord.y * self.mapWidth + oldArrCoord.x] = nil
                        
                        self.selectedElement = nil
                        
                        let turnScore = self.checkAndRemove(res: res)
                        if turnScore == 1 {
                            for i in 0 ..< 3 {
                                let pos = self.addRandomBall(ind: i)
                                if pos != nil {
                                    self.score += self.checkAndRemove(res: pos!, auto: true)
                                }
                                
                            }
                        }
                        self.score += turnScore
                        self.canSelect = true
                        self.scene?.updateScoreLabel()
                    })
                }
                
            }
        }

    }



}
