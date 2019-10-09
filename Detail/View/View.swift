import Foundation
import SnapKit
import UIComponents
import UIKit

final class View: UIView, ErrorPresentable {
    init() {
        super.init(frame: .zero)
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.allowsSelection = false
        view.tableFooterView = UIView()
        return view
    }()
}
