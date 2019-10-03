import AlamofireImage
import NSObject_Rx
import RxSwift
import SnapKit
import UIKit

final class AboutCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(horizontalStack)

        albumImageView.snp.makeConstraints {
            $0.size.equalTo(size)
        }
        
        horizontalStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        downLoadButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(20)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }

    func configure(with model: ViewModel.About) {
        albumTitleLabel.text = model.title
        albumTitleLabel.setNeedsLayout()

        if let url = model.imageURL {
            albumImageView.af_setImage(
                withURL: url,
                placeholderImage: UIImage(),
                filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 2.0)
            )
        } else {
            albumImageView.image = UIImage()
        }

        downLoadButton.buttonState = model.loadingState
    }

    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [albumTitleLabel, downLoadButton])
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .equalSpacing
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [albumImageView, verticalStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        return stack
    }()
    
    private var albumImageView = UIImageView()

    private(set) lazy var downLoadButton = DownloadButton()

    private lazy var albumTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    private let size = CGSize(width: 90, height: 90)
}
