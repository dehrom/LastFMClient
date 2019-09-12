import Foundation
import RxDataSources

struct ViewModel {
    let section: [Section]

    static let empty = ViewModel(section: [])

    struct Section: SectionModelType {
        let items: [Row]

        init(original: Section, items: [Row]) {
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
