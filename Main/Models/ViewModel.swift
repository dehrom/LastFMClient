import Foundation
import RxDataSources

struct ViewModel {
    let letters: [String]
    let section: [Section]

    static let empty = ViewModel(letters: [], section: [])

    struct Section: SectionModelType {
        let title: String
        let items: [Row]

        init(original: Section, items: [Row]) {
            title = original.title
            self.items = items
        }

        init(title: String, items: [Row]) {
            self.title = title
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
