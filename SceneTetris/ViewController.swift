//
//  ViewController.swift
//  SceneTetris
//
//  Created by mking on 10/16/17.
//  Copyright © 2017 mking. All rights reserved.
//

import UIKit
import SceneKit
import GameKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: SCNView!
    
    let tickInterval = Double(0.1)
    let height = 6
    let width = 2
    let scale = Float(0.1)
    var gameOver = false
    var fallingBlock: Block!
    var fallingBlockNode: SCNNode!
    var stillBlocks: [[Bool]]!
    var visibleBlockNode: SCNNode!
    var rs: GKRandomSource!
    var rd: GKRandomDistribution!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startGame()
    }
    
    func startGame() {
        rs = GKMersenneTwisterRandomSource(seed: 1780680306855649768)
        rd = GKRandomDistribution(randomSource: rs, lowestValue: 0, highestValue: width - 1)
        
        addScene()
        addFallingBlock()
        
        stillBlocks = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)
        Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
            self.processTick()
        }
    }
    
    func processTick() {
        if gameOver {
            return
        }
        
        let nextY = fallingBlock.y - 1
        if nextY == -1 || stillBlocks[nextY][fallingBlock.x] {
            // if nextY is invalid, stop falling
            
            if nextY == height - 1 {
                gameOver = true
                return
            }
            
            stillBlocks[fallingBlock.y][fallingBlock.x] = true
            addStillBlock()
            addFallingBlock()
        } else {
            // if nextY is valid, continue falling
            fallingBlock = Block(x: fallingBlock.x, y: nextY)
            animateFallingBlockPosition()
        }
    }
    
    func addFallingBlock() {
        let blockMaterial = SCNMaterial()
        blockMaterial.diffuse.contents = UIColor.orange
        let blockGeometry = SCNBox(width: CGFloat(scale), height: CGFloat(scale), length: CGFloat(scale), chamferRadius: 0.01)
        blockGeometry.firstMaterial = blockMaterial
        let blockNode = SCNNode(geometry: blockGeometry)
        blockNode.opacity = 0
        SCNTransaction.begin()
        SCNTransaction.animationDuration = tickInterval
        blockNode.opacity = 1
        SCNTransaction.commit()
        visibleBlockNode.addChildNode(blockNode)
        fallingBlockNode = blockNode
        
        let randomX = rd.nextInt(upperBound: width)
        fallingBlock = Block(x: randomX, y: height)
        updateFallingBlockPosition()
    }
    
    func addStillBlock() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = tickInterval
        fallingBlockNode.geometry!.firstMaterial!.diffuse.contents = UIColor.gray
        SCNTransaction.commit()
    }
    
    func updateFallingBlockPosition() {
        fallingBlockNode.position = SCNVector3(((Float(fallingBlock.x) + 0.5) - (Float(width) / 2)) * scale, Float(fallingBlock.y) * scale, 0)
    }
    
    func animateFallingBlockPosition() {
        // TODO rethink commit boundaries for animations
        SCNTransaction.begin()
        SCNTransaction.animationDuration = tickInterval
        updateFallingBlockPosition()
        SCNTransaction.commit()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
        }
    }
    
    func addScene() {
        let cubeMaterial = SCNMaterial()
        cubeMaterial.diffuse.contents = UIColor.clear
        let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        cubeGeometry.firstMaterial = cubeMaterial
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(0, 0, 0)
        
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1500
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(1.5, 1.5, 1.5)
        
        let camera = SCNCamera()
        let cameraConstraint = SCNLookAtConstraint(target: cubeNode)
        cameraConstraint.isGimbalLockEnabled = true
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(0, 0, 2)
        cameraNode.constraints = [cameraConstraint]
        cameraNode.camera = camera
        
        visibleBlockNode = SCNNode()
        
        // layer where blocks are born
        let ceilingMaterial = SCNMaterial()
        ceilingMaterial.diffuse.contents = UIColor.gray.withAlphaComponent(0.1)
        let ceilingGeometry = SCNBox(width: CGFloat(width) * CGFloat(scale), height: CGFloat(scale), length: CGFloat(scale), chamferRadius: 0)
        ceilingGeometry.firstMaterial = ceilingMaterial
        let ceilingNode = SCNNode()
        ceilingNode.geometry = ceilingGeometry
        ceilingNode.position = SCNVector3(0, Float(height) * scale, -scale / 2)
        
        // layer that stops blocks
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.gray.withAlphaComponent(0.1)
        let floorGeometry = SCNBox(width: CGFloat(width) * CGFloat(scale), height: CGFloat(scale), length: CGFloat(scale), chamferRadius: 0)
        floorGeometry.firstMaterial = floorMaterial
        let floorNode = SCNNode()
        floorNode.geometry = floorGeometry
        floorNode.position = SCNVector3(0, -scale, -scale / 2)

        let scene = SCNScene()
//        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(visibleBlockNode)
        scene.rootNode.addChildNode(ceilingNode)
        scene.rootNode.addChildNode(floorNode)
        sceneView.scene = scene
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

