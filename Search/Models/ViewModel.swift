import Foundation
import RxDataSources

enum ViewModel {
    case sections([Section])
    case empty(String)

    struct Section: SectionModelType {
        let items: [Row]

        init(original _: Section, items: [Row]) {
            self.items = items
        }

        init(items: [Row]) {
            self.items = items
        }

        struct Row: IdentifiableType {
            let title: String
            let imageURL: URL?

            var identity: String {
                return title
            }
        }
    }
}
