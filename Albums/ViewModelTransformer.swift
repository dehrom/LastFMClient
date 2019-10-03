import Foundation

final class ViewModelTransformer {
    func transform(from response: AlbumsResponse, with titlesOfSavedAlbums: [String]) -> ViewModel {
        let rows = response.topalbums
            .album
            .filter { $0.name != "(null)" }
            .map { album -> ViewModel.Album in
                let imageURL = album.image.lazy.filter { $0.size == .large }.compactMap { URL(string: $0.text) }.first
                let isLoaded = titlesOfSavedAlbums.contains(album.name)
                return .init(title: album.name, imageURL: imageURL, isLoaded: isLoaded)
            }
        return .init(sections: [.init(items: rows)])
    }
}
