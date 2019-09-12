import Foundation
import RxCocoa
import RxSwift

public enum UINavigationControllerObservingEventType {
    case willShow
    case didShow
}

public extension Reactive where Base: UIViewController {
    func showingStateObserver(for event: UINavigationControllerObservingEventType) -> Observable<Base> {
        return navigationControllerAccessor().flatMap { navigationControler -> ControlEvent<Reactive<Base>.ShowEvent> in
            switch event {
            case .willShow:
                return navigationControler.rx.willShow
            case .didShow:
                return navigationControler.rx.didShow
            }
        }.map { $0.viewController }
            .filter { [weak base] in $0 === base }
            .map { $0 as! Base }
    }

    private func navigationControllerAccessor() -> Observable<UINavigationController> {
        return methodInvoked(#selector(UIViewController.loadView))
            .map { [base] _ in base.navigationController }
            .flatMap(Observable.from(optional:))
    }
}
