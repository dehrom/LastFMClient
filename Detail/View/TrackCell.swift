import SnapKit
import UIKit

final class TrackCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(numberLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(durationLabel)

        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(6)
            make.width.equalTo(30)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(numberLabel.snp.trailing).inset(6)
            make.trailing.equalTo(durationLabel.snp.leading).inset(-4)
        }

        durationLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(6)
            make.width.equalTo(55)
            make.top.bottom.equalToSuperview().inset(6)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: ViewModel.Track) {
        numberLabel.attributedText = model.number
        titleLabel.text = model.title
        durationLabel.attributedText = model.duration
    }

    private lazy var numberLabel = createLabel()
    private lazy var titleLabel = createLabel()
    private lazy var durationLabel = createLabel()
}

private extension TrackCell {
    func createLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }
}
