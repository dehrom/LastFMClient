import Main
import RIBs

protocol Interactable: RIBs.Interactable, Main.Listener {
    var router: Routing? { get set }
    var listener: Listener? { get set }
}

protocol ViewControllable: RIBs.ViewControllable {
    func push(_ viewControllable: RIBs.ViewControllable)
}

final class Router: LaunchRouter<Interactable, ViewControllable>, Routing {
    init(interactor: Interactable, viewController: ViewControllable, mainBuilder: Main.Buildable) {
        self.mainBuilder = mainBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToMain() {
        let router = mainBuilder.build(withListener: interactor)
        attachChild(router)
        viewController.push(router.viewControllable)
    }

    private let mainBuilder: Main.Buildable
}
