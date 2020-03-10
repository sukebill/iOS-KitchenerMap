//
//  UIView + Extensions.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 10/03/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    func isHiddenAnimated(value: Bool, duration: Double = 0.2) {
        UIView.animate(withDuration: duration) { [weak self] in self?.isHidden = value }
    }
}
