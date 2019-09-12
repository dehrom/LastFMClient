import NSObject_Rx
import RIBs
import RIBsExtensions
import RxCocoa
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {
    func didTapOnSearchButton()
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?
    lazy var relay = BehaviorRelay<ViewModel>(value: .empty)

    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Albums"

        if item.rightBarButtonItem == nil {
            let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
            barButton.rx
                .tap
                .bind(onNext: { [weak listener] in listener?.didTapOnSearchButton() })
                .disposed(by: rx.disposeBag)
            item.rightBarButtonItem = barButton
        }

        return item
    }

    override func loadView() {
        let layout = UICollectionViewFlowLayout()
        let customView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        customView.backgroundColor = .white
        view = customView
        setupBindings(customView)
    }

    func push(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension ViewController {
    func setupBindings(_: UICollectionView) {}
}
