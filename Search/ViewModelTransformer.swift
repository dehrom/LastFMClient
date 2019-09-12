import Foundation

final class ViewModelTransformer {
    func tranform(from response: SearchResponse) -> ViewModel {
        let rows = response.results.artistmatches.artist.map { artist -> ViewModel.Section.Row in
            let imageURL = artist.image
                .lazy
                .filter { $0.size == .small }
                .compactMap { URL(string: $0.text) }
                .first

            return .init(title: artist.name, imageURL: imageURL)
        }
        return ViewModel(section: [.init(items: rows)])
    }
}
