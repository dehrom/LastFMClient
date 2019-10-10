import Detail
import RIBs
import RxSwift
import RIBsExtensions

protocol Interactable: RIBs.Interactable, Detail.Listener {
    var router: Routing? { get set }
    var listener: Listener? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {
    func push(_ viewControllable: RIBs.ViewControllable)
}

final class Router: ViewableRouter<Interactable, ViewControllable>, Routing {
    init(
        interactor: Interactable,
        viewController: ViewControllable,
        detailBuilder: Detail.Buildable
    ) {
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
        setupObserving()
    }

    func routeToDetails(artistName: String, albumTitle: String) {
        let router = detailBuilder.build(withListener: interactor, configuration: .init(artistName: artistName, albumTitle: albumTitle))
        attachChild(router)
        viewController.push(router.viewControllable)
    }

    func closeDetails() {
        guard let routing = children.first as? Detail.Routing else { return }
        detachChild(routing)
        routing.viewControllable.uiviewController.navigationController?.popViewController(animated: true)
    }

    private let detailBuilder: Detail.Buildable
    private let disposeBag = DisposeBag()
}

private extension Router {
    func detachChildren() {
        children.forEach(detachChild(_:))
    }
    
    func setupObserving() {
        viewControllable.uiviewController
            .rx
            .showingStateObserver(for: .didShow)
            .bind(onNext: { [weak self] _ in self?.detachChildren() })
            .disposed(by: disposeBag)
    }
}
