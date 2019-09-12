import RIBs
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {}

final class ViewController: UINavigationController, Presentable, ViewControllable {
    weak var listener: PresentableListener?

    func push(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        pushViewController(viewController, animated: true)
    }
}
