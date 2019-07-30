//
//  ToggleButton.swift
//  BirdID
//
//  Created by Tien Doan on 7/25/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import UIKit

class ToggleButton:UIButton{
    var isOn:Bool = false{
        didSet{
            updateDisplay()
        }
    }
    var onImage:UIImage! = nil{
        didSet{
            updateDisplay()
        }
    }
    var offImage:UIImage! = nil{
        didSet{
            updateDisplay()
        }
    }
    
    func updateDisplay(){
        if isOn {
            if let onImage = onImage{
                setBackgroundImage(onImage, for: .normal)
            }
        } else {
            if let offImage = offImage{
                setBackgroundImage(offImage, for: .normal)
            }
        }
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        isOn = !isOn
    }
}
