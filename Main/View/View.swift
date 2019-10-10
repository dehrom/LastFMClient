import SnapKit
import UIComponents
import UIKit

final class View: UIView, ErrorPresentable {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(offlineModeLabel)
        guard originalOffset == nil else { return }
        originalOffset = collectionView.contentOffset
    }

    func turnToOfflineMode() {
        addSubview(offlineModeLabel)
        offlineModeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(self.safeAreaInsets.top)
            $0.leading.width.equalToSuperview()
            $0.height.equalTo(30)
        }
        UIView.animate(withDuration: 0.5) {
            self.offlineModeLabel.alpha = 1
            self.collectionView.contentOffset.y -= 30
        }
    }

    func turnToOnlineMode() {
        UIView.animate(withDuration: 0.5, animations: {
            self.offlineModeLabel.alpha = 0
            self.collectionView.contentOffset = self.originalOffset ?? .zero
        }) { isFinished in
            guard isFinished == true else { return }
            self.offlineModeLabel.removeFromSuperview()
        }
    }

    private lazy var offlineModeLabel: UILabel = {
        let view = UILabel()
        view.alpha = 0
        view.backgroundColor = UIColor.darkGray
        view.textAlignment = .center
        view.numberOfLines = 1
        view.textColor = .white
        view.text = "You are now in offline mode"
        return view
    }()

    private var originalOffset: CGPoint?
}
