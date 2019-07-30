//
//  ModelDataHandler.swift
//  BirdID
//
//  Created by Tien Doan on 7/30/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//
import UIKit
import CoreImage

struct Inference {
    let confidence: Double
    let className: String
}

class ModelHandler {
    let wantedInputChannels = 3
    let wantedInputWidth = 224
    let wantedInputHeight = 224
    let resultCount = 3
    let threadCountLimit = 10
    var labels: [String] = []
    
    
    var birds_model = birds()
    
    func runModel(onFrame pixelBuffer: CVPixelBuffer) -> Inference? {
        
        let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        assert(sourcePixelFormat == kCVPixelFormatType_32ARGB ||
            sourcePixelFormat == kCVPixelFormatType_32BGRA || sourcePixelFormat == kCVPixelFormatType_32RGBA)
        
        
        let imageChannels = 4
        assert(imageChannels >= wantedInputChannels)
        
        // Crops the image to the biggest square in the center and scales it down to model dimensions.
        guard let thumbnailPixelBuffer = pixelBuffer.centerThumbnail(ofSize: CGSize(width: wantedInputWidth, height: wantedInputHeight)) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(thumbnailPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        do{
            let predict = try birds_model.prediction(input__0: thumbnailPixelBuffer)
//            list = predict.final_result__0.sorted(by:  {(s1,s2)->Bool in
//                if (s1.value > s2.value)
//                {
//                    return true
//                }
//                return false
//            })
            return Inference(confidence: predict.final_result__0[predict.classLabel] ?? 0, className: predict.classLabel)
        }catch{
            print(error)
        }
        return nil
    }
}
