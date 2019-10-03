import Albums
import RIBs
import RxSwift

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
    }

    func routeToAlbums(with artisName: String) {
        let router = albumsBuilder.build(withListener: interactor, and: .init(artistName: artisName))
        attachChild(router)
        viewController.push(router.viewControllable)
    }

    func detachChildren() {
        children.forEach(detachChild(_:))
    }

    private let albumsBuilder: Albums.Buildable
}
