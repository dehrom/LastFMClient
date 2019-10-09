import Foundation
import RxCocoa
import SnapKit
import UIKit

public protocol ErrorPresentable: AnyObject {
    func hideErrorMessage()
    func showErrorMessage(_ message: String)
    func showErrorMessage(_ message: String, withButtonText text: String) -> ControlEvent<Void>
}

public extension ErrorPresentable where Self: UIView {
    func hideErrorMessage() {
        let targetView = subviews.lazy.compactMap { $0 as? ErrorView }.first
        targetView?.removeFromSuperview()
    }

    func showErrorMessage(_ message: String) {
        let errorView = setupErrorView()
        errorView.showWith(errorText: message)
        errorView.reloadButton.isHidden = true
    }

    func showErrorMessage(_ message: String, withButtonText text: String) -> ControlEvent<Void> {
        let errorView = setupErrorView()
        errorView.showWith(errorText: message)
        errorView.reloadButton.isHidden = false
        errorView.reloadButton.setTitle(text, for: .normal)
        return errorView.reloadButton.rx.tap
    }

    private func setupErrorView() -> ErrorView {
        let targetView = subviews.lazy.compactMap { $0 as? ErrorView }.first ?? .init()

        if targetView.isDescendant(of: self) == false {
            addSubview(targetView)
            targetView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.edges.equalToSuperview()
            }
        }

        return targetView
    }
}
