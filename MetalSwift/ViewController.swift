//
//  ViewController.swift
//  MetalSwift
//
//  Created by Danny on 5/27/17.
//  Copyright © 2017 Danny. All rights reserved.
//

//https://www.raywenderlich.com/146416/metal-tutorial-swift-3-part-2-moving-3d

/**
 In this tutorial, you’ll get some hands-on experience using Metal and Swift to create a bare-bones app: drawing a simple triangle. In the process, you’ll learn about some of the most important classes in Metal, such as devices, command queues, and more.
 */

import UIKit
import Metal

class ViewController: UIViewController {
    var device:MTLDevice!
    var metalLayer: CAMetalLayer!
//    let vertexData:[Float] = [0.0,1.0,0.0,-1.0,-1.0,0.0,1.0,-1.0,0.0]
//    var objectToDraw:Triangle!
    var objectToDraw:Cube!

    var pipelineState : MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer:CADisplayLink!
    
    var projectionMatrix:Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        objectToDraw = Cube(device: device)
        
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(view.bounds.width/view.bounds.height), nearZ: 0.01, farZ: 100.0)
        

        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        

    }
    
    func newFrame(displayLink:CADisplayLink) {
        if lastFrameTimestamp == 0.0{
            lastFrameTimestamp = displayLink.timestamp
        }
        
        let elapsed : CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        gameloop(timeSinceLastUpdate: elapsed)
    }

    func gameloop(timeSinceLastUpdate:CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        autoreleasepool{
            self.render()
        }
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else {
            return
        }
        
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable,parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix,clearColor: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}



}
