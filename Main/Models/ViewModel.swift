import Foundation
import RxDataSources

enum ViewModel {
    case sections([Section])
    case empty(String)
    case isOnline(Bool)

    struct Section: AnimatableSectionModelType {
        let title: String
        var items: [Row]

        var identity: String {
            return title
        }

        init(title: String, items: [Row]) {
            self.title = title
            self.items = items
        }

        init(original: Section, items: [Row]) {
            title = original.title
            self.items = items
        }

        struct Row: IdentifiableType, Equatable {
            let title: String
            let imageURL: URL?

            var identity: String {
                return title
            }
        }
    }
}
