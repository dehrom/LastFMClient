import NSObject_Rx
import RIBs
import RIBsExtensions
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {
    var selectedModelRelay: PublishRelay<ViewModel.Section.Row> { get }

    func search(with artistName: String?)
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?

    lazy var relay = BehaviorRelay<ViewModel?>(value: nil)

    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Search artist"
        item.searchController = searchController
        item.hidesSearchBarWhenScrolling = false
        return item
    }

    override func loadView() {
        let customView = View()
        view = customView
        setupBindings(customView)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }

    func push(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        navigationController?.pushViewController(viewController, animated: true)
    }

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Enter artist's name"
        return controller
    }()

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<ViewModel.Section>(
        configureCell: { [weak self] in
            guard let self = self else { fatalError("self must not be nil!") }
            return self.configureCell(dataSource: $0, tableView: $1, indexPath: $2, model: $3)
        }
    )
}

private extension ViewController {
    func setupBindings(_ customView: View) {
        searchController.searchBar
            .rx
            .text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak listener] in listener?.search(with: $0) })
            .disposed(by: rx.disposeBag)

        relay.map { model -> [ViewModel.Section] in
            guard case let .sections(sections)? = model else { return [] }
            return sections
        }.bind(to: customView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        relay.map { model -> String? in
            guard case let .empty(string)? = model else { return nil }
            return string
        }.flatMap(Observable.from(optional:))
            .bind(onNext: customView.showErrorMessage(_:))
            .disposed(by: rx.disposeBag)

        customView.tableView
            .rx
            .itemSelected
            .bind(onNext: { customView.tableView.deselectRow(at: $0, animated: true) })
            .disposed(by: rx.disposeBag)

        customView.tableView
            .rx
            .modelSelected(ViewModel.Section.Row.self)
            .bind(onNext: { [weak listener] in listener?.selectedModelRelay.accept($0) })
            .disposed(by: rx.disposeBag)
    }

    func configureCell(
        dataSource _: TableViewSectionedDataSource<ViewModel.Section>,
        tableView: UITableView,
        indexPath _: IndexPath,
        model: ViewModel.Section.Row
    ) -> UITableViewCell {
        tableView.register(Cell.self, forCellReuseIdentifier: "\(Cell.self)")

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(Cell.self)") as? Cell
        else { fatalError("cell must have \(Cell.self) type!") }

        cell.configureWith(model)

        return cell
    }
}
