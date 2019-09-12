import RIBs
import RxSwift

protocol Interactable: RIBs.Interactable {
    var router: Routing? { get set }
    var listener: Listener? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {}

final class Router: ViewableRouter<Interactable, ViewControllable>, Routing {
    override init(interactor: Interactable, viewController: ViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func detachChildren() {
        children.forEach(detachChild(_:))
    }

    private let disposeBag = DisposeBag()
}
