import Foundation
import UIKit
import SnapKit

final class TitleView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        view.textColor = .black
        return view
    }()
}
