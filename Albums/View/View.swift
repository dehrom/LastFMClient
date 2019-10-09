import Foundation
import SnapKit
import UIComponents
import UIKit

final class View: UIView, ErrorPresentable {
    init() {
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.contentInset = UIEdgeInsets(top: 12, left: 4, bottom: 0, right: 4)
        return view
    }()
}
