import AlamofireImage
import SnapKit
import UIKit

final class AlbumCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(self).inset(10)
        }

        label.snp.makeConstraints { make in
            make.width.equalTo(imageView)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(6)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: ViewModel.Section.Row) {
        if let url = model.imageURL {
            imageView.af_setImage(
                withURL: url,
                filter: RoundedCornersFilter(radius: 2.0)
            )
        }
        label.text = model.title
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage()
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()

    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.numberOfLines = 1
        return view
    }()
}
