import Foundation
import RxCocoa
import RxSwift

// It's a part of my open-source library wich going to be published soon

public final class MutableStream<Element: Equatable>: ObservableType {
    public typealias E = Element
    
    public init() {}
    
    public func update(with newValue: Element) {
        relay.accept(newValue)
    }
    
    public func asImmutable() -> ImmutableStream<Element> {
        return .init(observable)
    }
    
    public func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, MutableStream.E == O.E {
        return observable.bind(to: observer)
    }
    
    private var relay = BehaviorRelay<Element?>(value: nil)
    
    private var observable: Observable<Element> {
        return relay.flatMap(Observable.from(optional:)).distinctUntilChanged()
    }
}

public final class ImmutableStream<Element: Equatable>: ObservableType {
    public typealias E = Element
    
    init(_ observable: Observable<Element>) {
        self.observable = observable
    }
    
    public func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, ImmutableStream.E == O.E {
        return observable.bind(to: observer)
    }
    
    private let observable: Observable<Element>
}
