import NSObject_Rx
import RIBs
import RIBsExtensions
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {
    var didSelectAlbumRelay: BehaviorRelay<Int?> { get }
    
    func didTapOnSearchButton()
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?
    lazy var relay = BehaviorRelay<ViewModel?>(value: nil)

    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Saved Albums"

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
        let customView = View()
        view = customView
        setupBindings(customView)
        navigationController?.navigationBar.prefersLargeTitles = false
        definesPresentationContext = true
    }

    func push(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        viewController.modalPresentationStyle = .popover
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }

    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<ViewModel.Section>(
        configureCell: { [weak self] in
            guard let self = self else { fatalError("self must not be nil") }
            return self.configureCell(dataSource: $0, collectionView: $1, indexPath: $2, model: $3)
        }
    )
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let side = (availableWidth / 2.1).rounded(.up)
        return CGSize(width: side, height: side)
    }
}

private extension ViewController {
    func setupBindings(_ customView: View) {
        customView.collectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        customView.collectionView.rx
            .itemSelected
            .map { $0.row }
            .bind(
                onNext: { [weak listener] in
                    listener?.didSelectAlbumRelay.accept($0)
                }
            ).disposed(by: rx.disposeBag)
        
        relay.map { model -> [ViewModel.Section] in
            guard case let .sections(sections)? = model else { return [] }
            return sections
        }.do(
            onNext: { _ in customView.hideWarning() }
        ).bind(to: customView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        relay.map { model -> String? in
            guard case let .empty(string)? = model else { return nil }
            return string
        }.flatMap(Observable.from(optional:))
            .bind(onNext: { customView.showWarning($0) })
            .disposed(by: rx.disposeBag)
    }

    func configureCell(
        dataSource _: CollectionViewSectionedDataSource<ViewModel.Section>,
        collectionView: UICollectionView,
        indexPath: IndexPath,
        model: ViewModel.Section.Row
    ) -> UICollectionViewCell {
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "\(AlbumCell.self)")

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "\(AlbumCell.self)",
                for: indexPath
            ) as? AlbumCell
        else { fatalError("unexpected cell type") }

        cell.configure(with: model)

        return cell
    }
}
