import RxDataSources

struct ViewModel {
    let sections: [Section]

    static let empty = ViewModel(sections: [])
}

extension ViewModel {
    struct Section: SectionModelType {
        var items: [Row]

        init(_ items: [Row]) {
            self.items = items
        }

        init(original _: Section, items: [Row]) {
            self.items = items
        }
    }

    enum Row {
        case about(About)
        case track(Track)
        case information(NSAttributedString)
    }

    struct About {
        let title: String
        let artistName: String
        let imageURL: URL?
        let loadingState: DownloadButton.ButtonState
    }

    struct Track {
        let title: String
        let number: NSAttributedString
        let duration: NSAttributedString
    }
}
