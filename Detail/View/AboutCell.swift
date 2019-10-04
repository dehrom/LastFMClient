import AlamofireImage
import NSObject_Rx
import RxSwift
import SnapKit
import UIKit

final class AboutCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(albumImageView)
        contentView.addSubview(verticalStack)
        
        albumImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(6)
        }
        
        verticalStack.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(6)
            $0.leading.equalTo(albumImageView.snp.trailing).offset(6)
        }

        downLoadButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(20)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }

    func configure(with model: ViewModel.About) {
        albumTitleLabel.text = model.title
        artistTitleLabel.text = model.artistName

        if let url = model.imageURL {
            albumImageView.af_setImage(
                withURL: url,
                filter: AspectScaledToFillSizeFilter(size: size),
                imageTransition: .crossDissolve(0.3)
            )
        } else {
            albumImageView.image = UIImage()
        }

        downLoadButton.buttonState = model.loadingState
    }

    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [albumTitleLabel, artistTitleLabel, downLoadButton])
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var albumImageView = UIImageView(frame: CGRect(origin: .zero, size: size))

    private(set) lazy var downLoadButton = DownloadButton()

    private lazy var albumTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 19, weight: .black)
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var artistTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.textColor = UIColor.lightGray
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    private let size = CGSize(width: 90, height: 90)
}
