//
//  KMSlider.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 07/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

class KMSlider: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var slider: UISlider!
    var onChangeAction: ((_ newValue: Float)->())?
    var onIdleAction: (()->())?
    private var date = Date()
    private weak var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("KMSlider", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func open() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkIfIdle), userInfo: nil, repeats: true)
        date = Date()
        timer?.fire()
    }
    
    func close() {
        timer?.invalidate()
    }
    func resetToDefaultValue() {
        slider.value = 1.0
    }
    @objc private func checkIfIdle() {
        guard Date().secondsSince(date) > 3 else {
            return
        }
        onIdleAction?()
    }
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        date = Date()
        onChangeAction?(sender.value)
    }
}
