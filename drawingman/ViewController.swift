//
//  ViewController.swift
//  drawingman
//
//  Created by Stephen Godderidge on 4/19/19.
//  Copyright © 2019 Stephen Godderidge. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var draw: UIButton!

    let configuration = ARWorldTrackingConfiguration()
    
    var currentColor = UIColor.red;
    var currentSize = CGFloat(0.02);
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
    }

    
    func getCurrentPositionOfCamera()->SCNVector3? {
        guard let pointOfView = self.sceneView.pointOfView else {return nil}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let position = orientation + location
        return position
    }
    
    func renderDrawingTip(position: SCNVector3){
        let tipNode = SCNNode(geometry: SCNSphere(radius: self.currentSize))
        tipNode.position = position
        tipNode.name = "tip"
        
        self.sceneView.scene.rootNode.enumerateChildNodes({(node, _) in
            if node.name == "tip" {
                node.removeFromParentNode()
            }
        })
        
        self.sceneView.scene.rootNode.addChildNode(tipNode)
        tipNode.geometry?.firstMaterial?.diffuse.contents = self.currentColor;
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if let currentPosition = getCurrentPositionOfCamera(){
            DispatchQueue.main.async{
                if self.draw.isHighlighted{
                    let sphereNode = SCNNode(geometry: SCNSphere(radius: self.currentSize))
                    sphereNode.position = currentPosition
                    self.sceneView.scene.rootNode.addChildNode(sphereNode)
                    sphereNode.geometry?.firstMaterial?.diffuse.contents = self.currentColor;
                } else {
                    self.renderDrawingTip(position: currentPosition)
                }
            }
        }
    }
    

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
