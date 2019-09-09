import Foundation

public protocol RequestParamsConvertible: Encodable {}

extension RequestParamsConvertible {
    func asDictionary() -> [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let parameters = obj as? [String: Any]
        else {
            return [:]
        }
        return parameters
    }
}
