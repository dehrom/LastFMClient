import NSObject_Rx
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class DownloadButton: UIControl {
    init() {
        super.init(frame: .zero)
        addSubview(label)
        addSubview(indicator)

        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        rx.controlEvent(.touchUpInside)
            .bind(
                onNext: {
                    UIView.animate(
                        withDuration: 0.33,
                        delay: 0,
                        options: .curveLinear,
                        animations: {
                            self.buttonState.nextState()
                        }
                    )
                }
            ).disposed(by: rx.disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var buttonState: ButtonState = .preloading {
        didSet {
            switch buttonState {
            case .preloading:
                label.text = "Download"
                isUserInteractionEnabled = true
                label.alpha = 1
                indicator.alpha = 0
                indicator.stopAnimating()
            case .loading:
                isUserInteractionEnabled = false
                label.text = ""
                label.alpha = 0
                indicator.alpha = 1
                indicator.startAnimating()
            case .loaded:
                label.text = "Remove"
                isUserInteractionEnabled = true
                label.alpha = 1
                indicator.alpha = 0
                indicator.stopAnimating()
            case .disabled:
                isUserInteractionEnabled = false
                label.text = "Download"
                label.alpha = 0.8
                indicator.alpha = 0
                indicator.stopAnimating()
            }
        }
    }

    private lazy var label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 15, weight: .heavy)
        view.textColor = .lightGray
        return view
    }()

    private lazy var indicator = UIActivityIndicatorView(style: .gray)
}

extension DownloadButton {
    enum ButtonState: Int {
        case preloading
        case loading
        case loaded
        case disabled

        mutating func nextState() {
            switch self {
            case .preloading:
                self = .loading
            case .loading:
                self = .loaded
            case .loaded:
                self = .preloading
            case .disabled:
                break
            }
        }
    }
}
