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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addCube()
    }
    
    func addCube() {
        let cubeMaterial = SCNMaterial()
        cubeMaterial.diffuse.contents = UIColor.blue
        let cubeGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
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
        cameraNode.position = SCNVector3(-3, 3, 3)
        cameraNode.constraints = [cameraConstraint]
        cameraNode.camera = camera

        let scene = SCNScene()
        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.scene = scene
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

