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

    lazy var relay = BehaviorRelay<ViewModel>(value: .empty)

    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Artists"
        item.searchController = searchController
        item.hidesSearchBarWhenScrolling = false
        
        return item
    }

    override func loadView() {
        let customView = UITableView(frame: .zero, style: .plain)
        customView.tableFooterView = UIView()
        view = customView
        setupBindings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search artist"
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
    func setupBindings() {
        guard let customView = view as? UITableView else { fatalError("view must not be nil!") }
        
        searchController.searchBar
            .rx
            .text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak listener] in listener?.search(with: $0) })
            .disposed(by: rx.disposeBag)
        
        relay.map { $0.section }
            .bind(to: customView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        customView.rx
            .itemSelected
            .bind(onNext: { customView.deselectRow(at: $0, animated: true) })
            .disposed(by: rx.disposeBag)

        customView.rx
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
