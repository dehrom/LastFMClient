import RxCocoa
import SnapKit
import UIKit

public final class ErrorView: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(warningLabel)
        addSubview(reloadButton)

        warningLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        reloadButton.snp.makeConstraints {
            $0.top.equalTo(warningLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWith(errorText: String) {
        warningLabel.text = errorText
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

    private(set) lazy var reloadButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitleColor(.darkGray, for: .normal)
        view.setTitleColor(.lightGray, for: .highlighted)
        view.setTitle("Reload", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return view
    }()
}
