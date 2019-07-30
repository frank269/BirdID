//
//  DetailViewController.swift
//  BirdID
//
//  Created by Tien Doan on 7/30/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import UIKit


class DetailViewController : UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ResultTxt: UILabel!
    
    var resultLabel : String = "No Result"
    var resultImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ResultTxt.text = resultLabel
        ImageView.image = resultImage
    }
    
}
