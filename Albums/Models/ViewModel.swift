import Foundation
import RxDataSources

struct ViewModel {
    let sections: [Section]

    static let empty = ViewModel(sections: [])
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
