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

    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<ViewModel.Section>.init(
        configureCell: { [weak self] in
            guard let self = self else { fatalError("self must not be nil") }
            return self.configureCell(dataSource: $0, collectionView: $1, indexPath: $2, model: $3)
        },
        configureSupplementaryView: { [weak self] in
            guard let self = self else { fatalError("self must not be nil") }
            return self.configureSupplementaryView(dataSource: $0, collectionView: $1, kind: $2, indexPath: $3)
        }
    )
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let side = (availableWidth / 2.1).rounded(.up)
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.inset(by: collectionView.layoutMargins).width, height: 60)
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

        relay.map { model -> Bool? in
            guard case let .isOnline(mode) = model else { return nil }
            return mode
        }.flatMap(Observable.from(optional:))
            .bind(
                onNext: { [navigationItem] mode in
                    switch mode {
                    case true:
                        navigationItem.rightBarButtonItem?.isEnabled = true
                        customView.turnToOnlineMode()
                    case false:
                        navigationItem.rightBarButtonItem?.isEnabled = false
                        customView.turnToOfflineMode()
                    }
                }
            ).disposed(by: rx.disposeBag)

        relay.map { model -> [ViewModel.Section]? in
            guard case let .sections(sections)? = model else { return nil }
            return sections
        }.flatMap(Observable.from(optional:))
            .do(
                onNext: { _ in customView.hideErrorMessage() }
            ).bind(to: customView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        relay.map { model -> String? in
            guard case let .empty(string)? = model else { return nil }
            return string
        }.flatMap(Observable.from(optional:))
            .bind(onNext: customView.showErrorMessage(_:))
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
    
    func configureSupplementaryView(
        dataSource: CollectionViewSectionedDataSource<ViewModel.Section>,
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView {
        collectionView.register(
            TitleView.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: "\(TitleView.self)"
        )
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(TitleView.self)",
            for: indexPath
        ) as? TitleView
        else { fatalError("unexpected cell type") }
        
        let title = dataSource.sectionModels[indexPath.section].title
        header.configure(with: title)
        
        return header
    }
}
