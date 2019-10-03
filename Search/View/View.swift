import SnapKit
import UIKit

final class View: UIView {
    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.tableFooterView = UIView()
        return view
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .white

        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWarning(_ text: String) {
        warningLabel.text = text
        addSubview(warningLabel)
        bringSubviewToFront(warningLabel)
        warningLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }

    func hideWarning() {
        warningLabel.removeFromSuperview()
    }

    private lazy var warningLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = .systemFont(ofSize: 20, weight: .heavy)
        view.textColor = .lightGray
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        return view
    }()
}
