//
//  KMTileRenderer.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 07/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation
import MapKit

class KMTileRendererLocal: MKTileOverlay {
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let tilePath = Bundle.main.url(forResource: "\(path.y)", withExtension: "png", subdirectory: "tiles/\(path.z)/\(path.x)", localization: nil)
        
        guard let tile = tilePath else {
            return Bundle.main.url(forResource: "bg", withExtension: "png", subdirectory: "tiles", localization: nil)!
        }
        return tile
    }
}

class KMTileRendererNetwork: MKTileOverlay {
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let tilePath = Bundle.main.url(forResource: "\(path.y)", withExtension: "png", subdirectory: "tiles/\(path.z)/\(path.x)", localization: nil)
        
        guard let tile = tilePath else {
            return Bundle.main.url(forResource: "bg", withExtension: "png", subdirectory: "tiles", localization: nil)!
        }
        return tile
    }
}
