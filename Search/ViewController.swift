import RIBs
import RxSwift
import RxCocoa
import UIKit
import RIBsExtensions
import NSObject_Rx

protocol PresentableListener: AnyObject {
    func search(with artistName: String)
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?
    
    lazy var relay = BehaviorRelay<ViewModel>(value: .empty)
    
    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        item.title = "Artists"
        item.searchController = searchController
        return item
    }
    
    override func loadView() {
        let customView = UITableView(frame: .zero, style: .grouped)
        customView.refreshControl = refreshControl
        customView.tableFooterView = UIView()
        view = customView
        setupBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        definesPresentationContext = true
    }
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search artist"
        return controller
    }()
    
    private lazy var refreshControl = UIRefreshControl()
}

private extension ViewController {
    func setupBindings() {
        searchController.searchBar
            .rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak listener] in listener?.search(with: $0) })
            .disposed(by: rx.disposeBag)
    }
}
