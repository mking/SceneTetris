//
//  ViewController.swift
//  SceneTetris
//
//  Created by mking on 10/16/17.
//  Copyright © 2017 mking. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: SCNView!
    
    let height = 10
    let scale = Float(0.1)
    var fallingBlock: Block? // TODO This should always be non-nil. A block is always falling (or the game is over).
    var fallingBlockNode: SCNNode!
    var stillBlocks: [Bool]!
    var visibleBlockNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startGame()
    }
    
    func startGame() {
        addScene()
        
        stillBlocks = [Bool](repeating: false, count: height)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.processTick()
        }
    }
    
    func processTick() {
        if fallingBlock != nil {
            let nextPosition = fallingBlock!.position - 1
            if nextPosition == 0 || stillBlocks[nextPosition] {
                // stop falling
                stillBlocks[fallingBlock!.position] = true
                fallingBlock = nil
                fallingBlockNode = nil
            } else {
                // fall
                fallingBlock!.position = nextPosition
                updateFallingBlockPosition()
            }
        }
    }
    
    func updateFallingBlockPosition() {
        fallingBlockNode.position = SCNVector3(0, Float(fallingBlock!.position) * scale, 0)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if fallingBlock == nil {
                // start falling
                fallingBlock = Block(position: height - 1)
                
                let blockMaterial = SCNMaterial()
                blockMaterial.diffuse.contents = UIColor.gray
                let blockGeometry = SCNBox(width: CGFloat(scale), height: CGFloat(scale), length: CGFloat(scale), chamferRadius: 0)
                blockGeometry.firstMaterial = blockMaterial
                fallingBlockNode = SCNNode(geometry: blockGeometry)
                updateFallingBlockPosition()
                visibleBlockNode.addChildNode(fallingBlockNode)
            }
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

        let scene = SCNScene()
//        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(visibleBlockNode)
        sceneView.scene = scene
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

