//
//  GuideViewController.swift
//  BirdID
//
//  Created by Tien Doan on 8/23/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//

import UIKit
import PDFKit

class GuideViewController : UIViewController {
    
    override func viewDidLoad() {
        let pdfView = PDFView(frame: self.view.bounds)
        self.view.addSubview(pdfView)
        
        // Fit content in PDFView.
        pdfView.autoScales = true
        
        let fileURL = Bundle.main.url(forResource: "guide", withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
    }
}
