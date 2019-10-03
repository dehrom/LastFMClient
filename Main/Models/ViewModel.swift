import Foundation
import RxDataSources

enum ViewModel {
    case sections([Section])
    case empty(String)

    struct Section: AnimatableSectionModelType {
        let title: String = ""
        let items: [Row]

        var identity: String {
            return title
        }

        init(original _: Section, items: [Row]) {
            self.items = items
        }

        init(items: [Row]) {
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
