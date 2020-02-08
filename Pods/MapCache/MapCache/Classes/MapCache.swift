//
//  MapCache.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import MapKit

extension MKTileOverlayPath {
    func realY(isReversed: Bool) -> Int {
        guard isReversed else { return y }
        let reversedY = Int(pow(Double(2), Double(z))) - y - 1
        return reversedY
    }
}
/// The real brain
public class MapCache : MapCacheProtocol {
    
    public var config : MapCacheConfig
    public var diskCache : DiskCache
    let operationQueue = OperationQueue()
    public var isYReversed: Bool = false
    
    public init(withConfig config: MapCacheConfig ) {
        self.config = config
        diskCache = DiskCache(withName: config.cacheName, capacity: config.capacity)
    }
    
    public func url(forTilePath path: MKTileOverlayPath) -> URL {
        var urlString = config.urlTemplate.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString.replacingOccurrences(of: "{y}", with: String(path.realY(isReversed: isYReversed)))
    
        urlString = urlString.replacingOccurrences(of: "{s}", with: config.roundRobinSubdomain() ?? "")
        return URL(string: urlString)!
    }
    
    public func cacheKey(forPath path: MKTileOverlayPath) -> String {
        return "\(config.urlTemplate)-\(path.x)-\(path.realY(isReversed: isYReversed))-\(path.z)"
    }
    
    public func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        // Use cache
        // is the file alread in the system?
        let key = cacheKey(forPath: path)
        
        // Fetch the data
        diskCache.fetchData(forKey: key, failure: { (error) in
            debugPrint ("MapCache::loadTile() Not found! cacheKey=\(key)" )
            let url = self.url(forTilePath: path)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("mobileSet=mobileAPIuser1&mobileSubSet=OesomEtaT",
                                    forHTTPHeaderField: "X-Application-Request-Origin")
            debugPrint ("MapCache::loadTile() url=\(url)")
            debugPrint("Requesting data....");
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                if error != nil {
                    debugPrint("!!! MapCache::loadTile Error for key= \(key)")
                    debugPrint(error as Any)
                    result(nil,error)
                    return
                }
                guard let data = data else { return }
                self.diskCache.setData(data, forKey: key)
                debugPrint ("CachedTileOverlay:: Data received saved cacheKey=\(key)" )
                result(data,nil)
            }
            task.resume()
        }, success: {(data) in
            debugPrint("MapCache::loadTile() found! cacheKey=\(key)" )
            result (data, nil)
            return
        })
       
    }
    
    public var diskSize: UInt64 {
        get  {
            return diskCache.diskSize
        }
    }
    
    public func calculateDiskSize() -> UInt64 {
        return diskCache.calculateDiskSize()
    }
    
    public func clear(completition: (() -> ())? ) {
        diskCache.removeAllData(completition)
    }
    
}
