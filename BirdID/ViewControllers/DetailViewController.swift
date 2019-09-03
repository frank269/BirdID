//
//  DetailViewController.swift
//  BirdID
//
//  Created by Tien Doan on 7/30/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import UIKit
import WebKit


class DetailViewController : UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ResultTxt: UILabel!
    @IBOutlet weak var webview: WKWebView!
    
    enum Result {
        case Found
        case notFound
    }
    
    var result:Result = .notFound
    var resultLabel : String = "No Result"
    var resultImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ResultTxt.text = resultLabel
        ImageView.image = resultImage
        
        switch result {
            case .Found:
                webview.isHidden = false
                webview.load(URLRequest(url: URL(string: "https://www.birdid.no/bird/eBook.php?specieID=1989")!))
            case .notFound:
                webview.isHidden = true
        }
        
    }
    
}
