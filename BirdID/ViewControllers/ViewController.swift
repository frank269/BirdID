//
//  ViewController.swift
//  BirdID
//
//  Created by Nguyen Dieu on 7/9/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    private let delayBetweenInferencesMs: Double = 1000
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    private let modelDataHandler: ModelHandler = ModelHandler()
    
    private var lastCheckLable:String = ""
    private var lastCheckCount: Int = 0
    private let THRESHOLD = 0.95
    
    
    @IBOutlet weak var previewView: PreviewView!
    
    private lazy var cameraCapture = CameraFeedManager(previewView: previewView)
    
    @IBOutlet weak var FlashBtn: ToggleButton!
    
    @IBAction func ChoosePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func ShowInfo(_ sender: UIButton) {
        let guideLlineScreen = self.storyboard?.instantiateViewController(withIdentifier: "GuideViewController") as! GuideViewController
        self.navigationController?.pushViewController(guideLlineScreen, animated: true)
    }
    
    @IBAction func TurnFlashOnOff(_ sender: ToggleButton) {
        FlashBtn.isOn = cameraCapture.turnFlash(on: sender.isOn)
    }
    
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cameraCapture.delegate = self
        
        FlashBtn.onImage = UIImage(named: "flash-on")
        FlashBtn.offImage = UIImage(named: "flash-off")
    }

    override func viewWillAppear(_ animated: Bool) {
        cameraCapture.checkCameraConfigurationAndStartSession()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if (IsNotFirstTimeUse){
            getDataFromDatabase()
        }else{
            getDataFromApi()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraCapture.stopSession()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let pixelbuffer = pixelBuffer(from: image)
        guard let result = modelDataHandler.runModel(onFrame: pixelbuffer) else {
            return
        }
        if(result.confidence > THRESHOLD && result.className != "Other"){
            gotoDetailScreen(image: image, name: "Kết quả: " + result.className + " - " + String(format: "%.2f", result.confidence * 100.0) + "%", found: true)
        }else{
            gotoDetailScreen(image: image, name: "Không tìm thấy gỗ", found: false)
        }
    }
    
    func gotoDetailScreen(image: UIImage, name: String, found: Bool) {
        let detailScreen = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailScreen.resultImage = image
        detailScreen.resultLabel = name
        if (found) {detailScreen.result = .Found } else { detailScreen.result = .notFound }
        
        self.navigationController?.pushViewController(detailScreen, animated: true)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func presentUnableToResumeSessionAlert() {
        let alert = UIAlertController(title: "Unable to Resume Session", message: "There was an error while attempting to resume session.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}
    
    // MARK: CameraFeedManagerDelegate Methods
    extension ViewController: CameraFeedManagerDelegate {
        
        func didOutput(pixelBuffer: CVPixelBuffer) {
            
            // Run the live camera pixelBuffer through tensorFlow to get the result
            
            let currentTimeMs = Date().timeIntervalSince1970 * 1000
            
            guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
                return
            }
            
            previousInferenceTimeMs = currentTimeMs
            guard let result = modelDataHandler.runModel(onFrame: pixelBuffer) else {
                return
            }
            
            print(result.className + " - " + String(format: "%.2f", result.confidence * 100.0) + "%")
            
            if (checkResult(result: result)) {
                
                //reset result
                lastCheckLable = ""
                lastCheckCount = 0
                
                //convert pixel Buffer to UIImage
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext(options: nil)
                guard let videoImage = context.createCGImage(ciImage, from: CGRect(x: 0,y: 0,width: CVPixelBufferGetWidth(pixelBuffer),height: CVPixelBufferGetHeight(pixelBuffer))) else{
                    return
                }
                DispatchQueue.main.sync {
                    self.gotoDetailScreen(image: UIImage(cgImage: videoImage), name: result.className + " - " + String(format: "%.2f", result.confidence * 100.0) + "%", found: true)
                }
            }
        }
        
        func checkResult(result : Inference) -> Bool {
            if(result.confidence > THRESHOLD && result.className != "Other" && result.className == lastCheckLable) {
                lastCheckCount += 1
            }
            else
            {
                lastCheckLable = result.className
                lastCheckCount = 0
            }
            
            if lastCheckCount > 1 {
                return true
            }
            else
            {
                return false
            }
        }
        
    // MARK: Session Handling Alerts
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        
        // Updates the UI when session is interupted.
        if resumeManually == true {
            //self.resumeButton.isHidden = false
        }
        else {
            //self.cameraUnavailableLabel.isHidden = false
        }
    }
    
    
    func sessionInterruptionEnded() {
        
        // Updates UI once session interruption has ended.
//        if !self.cameraUnavailableLabel.isHidden {
//            self.cameraUnavailableLabel.isHidden = true
//        }
        
//        if !self.resumeButton.isHidden {
//            self.resumeButton.isHidden = true
//        }
    }
    
    func sessionRunTimeErrorOccured() {
        // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
        //self.resumeButton.isHidden = false
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alertController = UIAlertController(title: "Camera Permissions Denied", message: "Camera permissions have been denied for this app. You can change this by going to Settings", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alert = UIAlertController(title: "Camera Configuration Failed", message: "There was an error while configuring camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
        }
    }

    
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer {
            let ciimage = CIImage(image: image)
            //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
            let tmpcontext = CIContext(options: nil)
            let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
            
            let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
            let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
            let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
            let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
            let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
            let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
            keysPointer.initialize(to: keys)
            valuesPointer.initialize(to: values)
            
            let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
            
            let width = cgimage!.width
            let height = cgimage!.height
            
            var pxbuffer: CVPixelBuffer?
            // if pxbuffer = nil, you will get status = -6661
            var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                             kCVPixelFormatType_32BGRA, options, &pxbuffer)
            status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
            
            let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
            
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
            let context = CGContext(data: bufferAddress,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesperrow,
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
            context?.concatenate(CGAffineTransform(rotationAngle: 0))
            context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
            //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
            
            
            context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
            status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
            return pxbuffer!;
            
}

