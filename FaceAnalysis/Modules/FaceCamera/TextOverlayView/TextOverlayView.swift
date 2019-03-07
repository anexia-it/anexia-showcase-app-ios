//
//  TextOverlayView.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 05.11.18.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit

class TextOverlayView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView(){
        view = loadViewFromXibFile()
        addSubview(view)
        view.frame = self.bounds
        view.layer.cornerRadius = 10
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TextOverlayView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func displayView(onView: UIView){
        onView.addSubview(self)
    }
    
    func setText(text: String){
        textLabel.text = text
        setNeedsLayout()
    }
}

