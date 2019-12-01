//
//  Router.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 01/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import CoreLocation

enum Route {
    case feedback(coordinates: CLLocationCoordinate2D)
}

extension Route {
    var viewController: UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .feedback(let coordinates):
            let destination = storyBoard.instantiateViewController(withClass: TakeCommentViewController.self)!
            destination.location = coordinates
            return destination
        }
    }
}

extension Route {
    func push(from viewController: UIViewController) {
        viewController.navigationController?.pushViewController(self.viewController)
    }
    
    func present(from viewController: UIViewController, animated: Bool = true) {
        viewController.present(self.viewController, animated: animated)
    }
}
