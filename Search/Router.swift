import Albums
import RIBs
import RxSwift
import RIBsExtensions

protocol Interactable: RIBs.Interactable, Albums.Listener {
    var router: Routing? { get set }
    var listener: Listener? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {
    func push(_ viewControllable: RIBs.ViewControllable)
}

final class Router: ViewableRouter<Interactable, ViewControllable>, Routing {
    init(interactor: Interactable, viewController: ViewControllable, albumsBuilder: Albums.Buildable) {
        self.albumsBuilder = albumsBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
        setupObserving()
    }

    func routeToAlbums(with artisName: String) {
        let router = albumsBuilder.build(withListener: interactor, and: .init(artistName: artisName))
        attachChild(router)
        viewController.push(router.viewControllable)
    }

    private let albumsBuilder: Albums.Buildable
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
