//
//  MenuViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 07/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

protocol MenuDelegate: class {
    func didTapFilter()
}

class MenuViewController: UIViewController {
    
    var delegate: MenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onTransparencyTapped(_ sender: Any) {
        delegate?.didTapFilter()
    }
}
