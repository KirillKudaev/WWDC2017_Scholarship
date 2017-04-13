import UIKit
import SpriteKit
import PlaygroundSupport

class Maze {
    
    var mazeArray: [[Brick]] = []

    enum Brick {
        case Empty, Filled
    }
    
    // Generate a random maze
    init(width: Int, height: Int) {
        for i in 0 ..< height {
            mazeArray.append([Brick](repeating: Brick.Filled, count: width))
        }
        
        for i in 0 ..< width {
            mazeArray[0][i] = Brick.Empty
            mazeArray[height - 1][i] = Brick.Empty
        }
        
        for i in 0 ..< height {
            mazeArray[i][0] = Brick.Empty
            mazeArray[i][width - 1] = Brick.Empty
        }
        
        mazeArray[2][2] = Brick.Empty
        self.mazeBrickPlace(x: 2, y: 2)
        mazeArray[1][2] = Brick.Empty
        mazeArray[height - 2][width - 3] = Brick.Empty
    }
    
    // Recursively generate maze starting at (x, y)
    func mazeBrickPlace(x: Int, y: Int) {
        var count = 0
        let moveX = [1, -1, 0, 0]
        let moveY = [0, 0, 1, -1]
        var dir = Int(arc4random_uniform(4))
        while count <= 3 {
            let x1 = x + moveX[dir]
            let y1 = y + moveY[dir]
            let x2 = x1 + moveX[dir]
            let y2 = y1 + moveY[dir]
            if mazeArray[y1][x1] != Brick.Filled || mazeArray[y2][x2] != Brick.Filled {
                dir = (dir + 1) % 4
                count += 1
            } else {
                mazeArray[y1][x1] = Brick.Empty
                mazeArray[y2][x2] = Brick.Empty
                mazeBrickPlace(x: x2, y: y2)
            }

        }
    }
    
    func getMazeArray() -> [[Brick]] {
        return mazeArray
    }
}

class Scene: SKScene, SKPhysicsContactDelegate {
    
    
    // To detect collisions between objects
    struct CategoryBitMask {
        static let Ball: UInt32 = 0b1 << 0
        static let Wall: UInt32 = 0b1 << 1
    }
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: 780, height: 780)
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Disable gravity
        
        // Create an invisible barrier around the scene to keep the ball inside.
        let sceneBound = SKPhysicsBody(edgeLoopFrom: self.frame)
        sceneBound.friction = 0
        sceneBound.restitution = 1
        self.physicsBody = sceneBound
        
        // Create a ball to bounce around the maze.

        let ball = SKSpriteNode(imageNamed: "ball.png")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.categoryBitMask = CategoryBitMask.Ball
        ball.physicsBody!.contactTestBitMask = CategoryBitMask.Wall
        ball.physicsBody!.friction = 0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.velocity = CGVector(dx: 200, dy: 200)
        ball.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height)
        self.addChild(ball)
        
        // Create a template for a wall block.
        let block = SKSpriteNode(color: SKColor.white, size: CGSize(width: 50, height: 50))
        block.name = "Whole"
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody!.categoryBitMask = CategoryBitMask.Wall
        block.physicsBody!.isDynamic = false
        block.physicsBody!.friction = 0
        block.physicsBody!.restitution = 1
        
        let maze = Maze(width: 14, height: 14)
        var mazeArray = maze.getMazeArray()

        // Build a maze using SpriteNodes
        for y in 1...14 {
            for x in 1...14 {
                
                if mazeArray[y-1][x-1] == Maze.Brick.Empty {
                    let b = block.copy() as! SKSpriteNode
                    b.color = UIColor.white
                    b.position = CGPoint(x: (b.size.width) * CGFloat(x), y: (b.size.height) * CGFloat(y))
                    self.addChild(b)
                }
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // Executed if the ball makes contact with the block.
        if contact.bodyA.categoryBitMask == CategoryBitMask.Ball && contact.bodyB.categoryBitMask == CategoryBitMask.Wall {
            let wallBlock = contact.bodyB.node as! SKSpriteNode

            // Change block's color to pink if it was hit for the first time
            if wallBlock.name == "Whole" {
                wallBlock.color = #colorLiteral(red: 0.9686274529, green: 0.7107819597, blue: 0.9381260148, alpha: 1)
                wallBlock.name = "Damaged"
            } else {
                // Remove the damaged wall block if it was hit again
                wallBlock.removeFromParent()
            }
        }
    }
}

let scene = Scene()
scene.scaleMode = .aspectFit

let view = SKView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
view.presentScene(scene)
PlaygroundPage.current.liveView = view

let button = UIButton(frame: CGRect(x: 85, y: 5, width: 400, height: 40))
button.setTitle("👉 Click to generate a new random maze 👈", for: .normal)

let label = UILabel(frame: CGRect(x: 200, y: 560, width: 160, height: 20))
label.text = ""
label.font = label.font.withSize(10)
label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

class Receiver {
    @objc func buttonClicked() {
        button.isEnabled = false
        let scene = Scene()
        view.presentScene(scene)
        button.setTitle("I hope you liked it ☺️", for: .normal)
        label.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        label.text = "I've also attached my résumé 🤓"
    }
}

let receiver = Receiver()

button.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
button.addTarget(receiver, action: #selector(Receiver.buttonClicked), for: .touchUpInside)
PlaygroundPage.current.liveView = view
view.addSubview(button)
view.addSubview(label)
