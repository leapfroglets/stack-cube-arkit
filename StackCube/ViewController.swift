//
//  ViewController.swift
//  StackCube
//
//  Created by Sujan Vaidya on 8/18/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
  @IBOutlet weak var sceneView: ARSCNView!
  @IBOutlet weak var cameraState: UILabel!
  @IBOutlet weak var planeDetection: UILabel!
  var anchors: [ARPlaneAnchor] = []
  var planeHeight: CGFloat = 0.01
  var objects: [SCNNode] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    sceneView.showsStatistics = true
    self.sceneView.autoenablesDefaultLighting = true
    self.sceneView.debugOptions  = [ARSCNDebugOptions.showFeaturePoints]
    self.sceneView.showsStatistics = true
    self.sceneView.automaticallyUpdatesLighting = true
    setSessionConfiguration()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  
  var configuration = ARWorldTrackingConfiguration()
  
  func setSessionConfiguration() {
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: sceneView)
    let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
    if hitResults.count > 0 {
      let result: ARHitTestResult = hitResults.first!
      
      let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
      addCube(location: newLocation)
    }
  }
  
  func addCube(location: SCNVector3) {
    let dimension: CGFloat = 0.1
    var cubePosition = location
    cubePosition.y += 0.5
    let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
    let cubeNode = SCNNode(geometry: cube)
    let img = UIImage(named: "Box.jpg")
    let material = SCNMaterial()
    material.diffuse.contents = img
    cube.materials = [material, material, material, material, material, material]
    cubeNode.position = cubePosition
    cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cube, options: nil))
    objects.append(cubeNode)
    sceneView.scene.rootNode.addChildNode(cubeNode)
  }
  
  @IBAction func reset(_ sender: UIButton) {
    planeDetection.text = ""
    removeAllObjects()
    setSessionConfiguration()
  }
  
  func removeAllObjects() {
    for object in objects {
      object.removeFromParentNode()
    }
    objects = []
  }
  
}

extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    var node:  SCNNode?
    if let planeAnchor = anchor as? ARPlaneAnchor {
      DispatchQueue.main.async {
        self.planeDetection.text = "Plane detected"
      }
      let rotationX = anchor.transform.columns.1.y
      var planeType = "Floor"
      if rotationX < 0 {
        planeType = "Ceiling"
      }
      print ("plane type is: ", planeType)
      node = SCNNode()
      let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
      planeGeometry.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.4)
      let planeNode = SCNNode(geometry: planeGeometry)
      planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
      planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
      node?.addChildNode(planeNode)
      anchors.append(planeAnchor)
      
    } else {
      print("not plane anchor \(anchor)")
    }
    return node
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor {
      if anchors.contains(planeAnchor) {
        if node.childNodes.count > 0 {
          let planeNode = node.childNodes.first!
          planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
          planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
          if let plane = planeNode.geometry as? SCNBox {
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.length = CGFloat(planeAnchor.extent.z)
            plane.height = planeHeight
          }
        }
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    print("here")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    print("Interupted")
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    let trackingState = camera.trackingState
    var cameraStateString = ""
    
    switch(trackingState) {
    case .notAvailable:
      cameraStateString = "Camera tracking is not available on this device"
      
    case .limited(let reason):
      switch(reason) {
      case .excessiveMotion:
        cameraStateString = "Limited tracking: slow down the movement of the device"
        
      case .insufficientFeatures:
        cameraStateString = "Limited tracking: too few feature points, view areas with more textures"
        
      case .initializing:
        cameraStateString = "Initializing"
      }
      
    case .normal:
      cameraStateString = "Tracking is back to normal"
    }
    cameraState.text = cameraStateString
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    print("Error: ", error)
  }
}
