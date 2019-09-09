import Foundation

extension Dictionary {
    func merge(with dictionaries: Dictionary..., uniqueValueSelector: ((Value, Value) -> Value)? = nil) -> Dictionary {
        var result = self

        for dictionary in dictionaries {
            for (key, value) in dictionary {
                if let oldValue = result[key] {
                    let uniqueValue = uniqueValueSelector?(oldValue, value) ?? value
                    result[key] = uniqueValue
                } else {
                    result[key] = value
                }
            }
        }

        return result
    }
}
