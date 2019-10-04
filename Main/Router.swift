import RIBs
import RIBsExtensions
import RxCocoa
import RxSwift
import Search
import Detail

protocol Interactable: RIBs.Interactable, Search.Listener, Detail.Listener {
    var router: Routing? { get set }
    var listener: Listener? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {
    func push(_ viewControllable: RIBs.ViewControllable)
    func present(_ viewControllable: RIBs.ViewControllable)
}

final class Router: ViewableRouter<Interactable, ViewControllable>, Routing {
    init(interactor: Interactable, viewController: ViewControllable, searchBuilder: Search.Buildable, detailBuilder: Detail.Buildable) {
        self.searchBuilder = searchBuilder
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
        setupObserving()
    }

    func routeToSearchScreen() {
        let router = searchBuilder.build(withListener: interactor)
        attachChild(router)
        viewController.push(router.viewControllable)
    }
    
    func routeToDetails(artistName: String, albumTitle: String) {
        let router = detailBuilder.build(
            withListener: interactor,
            configuration: .init(artistName: artistName, albumTitle: albumTitle)
        )
        attachChild(router)
        viewController.present(router.viewControllable)
    }

    func detachChildren() {
        children.forEach(detachChild(_:))
    }

    private let searchBuilder: Search.Buildable
    private let detailBuilder: Detail.Buildable
    
    private let disposeBag = DisposeBag()
}

private extension Router {
    func setupObserving() {
        viewControllable.uiviewController
            .rx
            .showingStateObserver(for: .didShow)
            .skip(2)
            .bind(onNext: { [weak self] _ in self?.detachChildren() })
            .disposed(by: disposeBag)
    }
}
