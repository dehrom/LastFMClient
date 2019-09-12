import AlamofireImage
import UIKit

final class Cell: UITableViewCell {
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 14)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        imageView?.af_cancelImageRequest()
    }

    func configureWith(_ model: ViewModel.Section.Row) {
        if let url = model.imageURL {
            imageView?.af_setImage(withURL: url, filter: CircleFilter())
        } else {
            imageView?.image = UIImage()
        }
        textLabel?.text = model.title
    }
}
