import Foundation
import RealmSwift
import RxSwift

public extension Realm {
    static func get() -> Realm {
        return try! Realm()
    }
}

public extension Reactive where Base: Realm {
    static func execute<T>(_ handler: @escaping (Realm) throws -> T) -> Maybe<T> {
        return .create { subscriber in
            do {
                let realm = try Realm()
                subscriber(.success(try handler(realm)))
                subscriber(.completed)
            } catch {
                subscriber(.error(error))
            }
            return Disposables.create()
        }
    }
}
