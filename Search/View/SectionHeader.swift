import SnapKit
import UIKit

final class SectionHeader: UIView {
    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(23)
            make.bottom.equalToSuperview().inset(4)
            make.top.equalToSuperview().offset(4)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
}
