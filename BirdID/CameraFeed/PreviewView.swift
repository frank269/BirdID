//
//  PreviewView.swift
//  BirdID
//
//  Created by Nguyen Dieu on 7/9/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import AVFoundation
import UIKit

class PreviewView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Layer expected is of type VideoPreviewLayer")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            previewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
