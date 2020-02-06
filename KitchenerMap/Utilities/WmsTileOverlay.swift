import Foundation

extension String {
    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as String
        return nsSt.appendingPathComponent(path)
    }
}

