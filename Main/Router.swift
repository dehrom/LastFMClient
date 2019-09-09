import RIBs
import Search
import RxCocoa
import RIBsExtensions
import RxSwift

protocol Interactable: RIBs.Interactable, Search.Listener {
    var router: Routing? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {
    func push(_ viewControllable: RIBs.ViewControllable)
}

final class Router: LaunchRouter<Interactable, ViewControllable>, Routing {
    init(interactor: Interactable, viewController: ViewControllable, searchBuilder: Search.Buildable) {
        self.searchBuilder = searchBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
        setupObserving()
    }

    func routeToSearchScreen() {
        let router = searchBuilder.build(withListener: interactor)
        attachChild(router)
        viewController.push(router.viewControllable)
    }
    
    func detachChildren() {
        children.forEach(detachChild(_:))
    }
    
    private let searchBuilder: Search.Buildable
    private let disposeBag = DisposeBag()
}

private extension Router {
    func setupObserving() {
        guard
            let navigationController = viewController.uiviewController as? UINavigationController,
            let mainViewController = navigationController.viewControllers.first as? ViewController
        else { fatalError("AAAAAAA") }
        
        navigationController.rx.observeStack(for: mainViewController, with: .didShow)
            .bind(onNext: { [weak self] _ in self?.detachChildren() })
            .disposed(by: disposeBag)
    }
}
