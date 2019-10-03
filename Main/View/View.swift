import SnapKit
import UIKit

final class View: UIView {
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.contentInset = UIEdgeInsets(top: 12, left: 4, bottom: 0, right: 4)
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white

        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
