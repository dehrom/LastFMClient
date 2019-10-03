import Detail
import RIBs

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
    }

    func routeToDetails(artistName: String, albumTitle: String) {
        let router = detailBuilder.build(withListener: interactor, configuration: .init(artistName: artistName, albumTitle: albumTitle))
        attachChild(router)
        viewController.push(router.viewControllable)
    }

    private let detailBuilder: Detail.Buildable
}
