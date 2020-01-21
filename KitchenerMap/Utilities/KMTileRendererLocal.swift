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
        let reversedY = Int(pow(2.0, Double(path.z))) - path.y - 1
        let pp = "https://gaia.hua.gr/tms/kitchener_review/\(path.z)/\(path.x)/\(reversedY).jpg"
        return URL(string: pp)!
    }
}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
}

class WMSMKTileOverlay: MKTileOverlay {
    
    var url: String
    var useMercator: Bool
    var alpha: CGFloat = 1.0
    
    init(urlArg: String, useMercatorArg: Bool) {
        self.url = urlArg
        self.useMercator = useMercatorArg
        super.init(urlTemplate: url)
    }
    
    
    // MapViewUtils
    
    let TILE_SIZE = 256.0
    let MINIMUM_ZOOM = 0
    let MAXIMUM_ZOOM = 25
    let TILE_CACHE = "TILE_CACHE"
    
    func tileZ(zoomScale: MKZoomScale) -> Int {
        let numTilesAt1_0 = MKMapSize.world.width / TILE_SIZE
        let zoomLevelAt1_0 = log2(Float(numTilesAt1_0))
        let zoomLevel = max(0, zoomLevelAt1_0 + floor(log2f(Float(zoomScale)) + 0.5))
        return Int(zoomLevel)
    }
    
    func xOfColumn(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return x / pow(2.0, z) * 360.0 - 180
    }
    
    func yOfRow(row: Int, zoom: Int) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = Double.pi - 2.0 * Double.pi * y / pow(2.0, z)
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
    
    func mercatorXofLongitude(lon: Double) -> Double {
        return lon * 20037508.34 / 180
    }
    
    func mercatorYofLatitude(lat: Double) -> Double {
        var y = log(tan((90 + lat) * Double.pi / 360)) / (Double.pi / 180)
        y = y * 20037508.34 / 180
        return y
    }
    
    func md5Hash(stringData: NSString) -> NSString {
        let str = stringData.cString(using: String.Encoding.utf8.rawValue)
        let strLen = CUnsignedInt(stringData.lengthOfBytes(using: String.Encoding.utf8.rawValue))
        
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        
        return String(format: hash as String) as NSString
    }
    
    func createPathIfNecessary(path: String) -> Bool {
        var succeeded = true
        let fm = FileManager.default
        if(!fm.fileExists(atPath: path)) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                succeeded = true
            } catch _ {
                succeeded = false
            }
        }
        return succeeded
    }
    
    func cachePathWithName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let cachesPath: String = paths as String
        let cachePath = name.stringByAppendingPathComponent(cachesPath)
        createPathIfNecessary(path: cachesPath)
        createPathIfNecessary(path: cachePath)
        
        return cachePath
    }
    
    
    func getFilePathForURL(url: NSURL, folderName: String) -> String {
        return cachePathWithName(name: folderName).stringByAppendingPathComponent(md5Hash(stringData: "\(url)" as NSString) as String)
    }
    
    func cacheUrlToLocalFolder(url: NSURL, data: NSData, folderName: String) {
        let localFilePath = getFilePathForURL(url: url, folderName: folderName)
        data.write(toFile: localFilePath, atomically: true)
    }
    
    // MapViewUtils END ************
    
    
    func urlForTilePath(path: MKTileOverlayPath) -> NSURL {
        var left   = xOfColumn(column: path.x, zoom: path.z) // minX
        var right  = xOfColumn(column: path.x+1, zoom: path.z) // maxX
        var bottom = yOfRow(row: path.y+1, zoom: path.z) // minY
        var top    = yOfRow(row: path.y, zoom: path.z) // maxY
        
        if self.useMercator {
            left   = mercatorXofLongitude(lon: left) // minX
            right  = mercatorXofLongitude(lon: right) // maxX
            bottom = mercatorYofLatitude(lat: bottom) // minY
            top    = mercatorYofLatitude(lat: top) // maxY
        }
        
        let resolvedUrl = "\(self.url)&BBOX=\(left),\(bottom),\(right),\(top)"
        
        return NSURL(string: resolvedUrl)!
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
         let url1 = self.urlForTilePath(path: path)
               let filePath = getFilePathForURL(url: url1, folderName: TILE_CACHE)
               let file = FileManager.default
               if file.fileExists(atPath: filePath) {
                   let tileData = try? NSData(contentsOfFile: filePath, options: .mappedIfSafe) as Data
                   result(tileData, nil)
               }
               else {
                   var request = URLRequest(url: url1 as URL)
                   request.httpMethod = "GET"
                   
                   let session = URLSession.shared
                   session.dataTask(with: request, completionHandler: {(data, response, error) in
                       
                       if error != nil {
                           print("Error downloading tile")
                           result(nil, error)
                       }
                       else {
                        try? (data as NSData?)?.write(to: url1 as URL, options: .atomic)
                           result(data, error)
                       }
                   }).resume()

               }
    }
    
    
}
