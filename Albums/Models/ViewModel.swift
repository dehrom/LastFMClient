import Foundation
import RxDataSources

enum ViewModel {
    case models([Section])
    case empty(String)
}

extension ViewModel {
    struct Section: AnimatableSectionModelType {
        let title = ""
        let items: [Album]

        init(original _: Section, items: [Album]) {
            self.items = items
        }

        init(items: [Album]) {
            self.items = items
        }

        var identity: String {
            return title
        }
    }

    struct Album: IdentifiableType, Equatable {
        let identity: String
        let title: NSAttributedString
        let imageURL: URL?
    }
}
