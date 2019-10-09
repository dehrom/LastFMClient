import Foundation
import ManagedModels

final class ViewModelTransformer {
    func transform(from models: [AlbumManagedModel]) -> ViewModel {
        guard
            models.isEmpty == false
        else {
            return .empty("There are no saved albums in your library")
        }
        
        let artistsTitles = Set(models.compactMap { $0.artist?.title })
        let sections = artistsTitles.reduce(into: [ViewModel.Section]()) { buffer, next in
            let rows = models.filter { $0.artist?.title == next }.map { album -> ViewModel.Section.Row in
                let imageURL = album.imageURL.map { URL(string: $0) } ?? nil
                return .init(title: album.title, imageURL: imageURL)
            }
            buffer.append(.init(title: next, items: rows))
        }

        return .sections(sections)
    }
}
