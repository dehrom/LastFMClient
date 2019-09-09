import Foundation
import RxCocoa
import RxSwift

public enum UINavigationControllerObservingEventType {
    case willShow
    case didShow
}

public extension Reactive where Base: UINavigationController {
    func observeStack<ViewController>(
        for viewController: ViewController,
        with eventType: UINavigationControllerObservingEventType
    ) -> Observable<ViewController> where ViewController: UIViewController {
        let source = { () -> ControlEvent<(viewController: UIViewController, animated: Bool)> in
            switch eventType {
            case .willShow:
                return self.willShow
            case .didShow:
                return self.didShow
            }
        }
        
        return source().debug("observeStack 0 ").map {
            $0.viewController as? ViewController
        }.debug("observeStack 1 ").flatMap(Observable.from(optional:))
        .filter { [weak viewController] in $0 === viewController }
        .debug("observeStack 2 ")
    }
}
