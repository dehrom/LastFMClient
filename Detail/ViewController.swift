import NSObject_Rx
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {
    func didPressDownload()
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?

    lazy var relay = BehaviorRelay<ViewModel>(value: .empty)

    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Tracks"
        return item
    }

    override func loadView() {
        let customView = UITableView(frame: .zero, style: .plain)
        customView.allowsSelection = false
        customView.tableFooterView = UIView()
        view = customView
        setupBindings(customView)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<ViewModel.Section>(
        configureCell: { [weak self] in
            guard let self = self else { fatalError("self must not be nil") }
            return self.configureCell(dataSource: $0, tableView: $1, indexPath: $2, model: $3)
        }
    )
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // yep, it's because of AlamofireImage is not set correct size to image at first time, don't know why :(
        guard
            indexPath.row == 0 && indexPath.section == 0
        else { return UITableView.automaticDimension }
        return 102
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

private extension ViewController {
    func configureCell(
        dataSource _: TableViewSectionedDataSource<ViewModel.Section>,
        tableView: UITableView,
        indexPath: IndexPath,
        model: ViewModel.Row
    ) -> UITableViewCell {
        [
            AboutCell.self, TrackCell.self, InformationCell.self,
        ].forEach {
            tableView.register($0, forCellReuseIdentifier: "\($0!)")
        }

        switch (model, tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath)) {
        case let (.about(model), cell as AboutCell):
            cell.configure(with: model)
            cell.downLoadButton
                .rx
                .controlEvent(.touchUpInside)
                .bind(
                    onNext: { [weak self] in
                        self?.listener?.didPressDownload()
                    }
                ).disposed(by: cell.rx.disposeBag)
            return cell
        case let (.track(model), cell as TrackCell):
            cell.configure(with: model)
            return cell
        case let (.information(text), cell as InformationCell):
            cell.configure(with: text)
            return cell
        case (_, _):
            fatalError("Unexpected model-cell pair!")
        }
    }

    func setupBindings(_ customView: UITableView) {
        customView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        relay.map { $0.sections }
            .filter { $0.isEmpty == false }
            .bind(to: customView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}

private extension ViewModel.Row {
    var cellIdentifier: String {
        switch self {
        case .about:
            return "\(AboutCell.self)"
        case .track:
            return "\(TrackCell.self)"
        case .information:
            return "\(InformationCell.self)"
        }
    }
}
