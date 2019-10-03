import Foundation
import ManagedModels

final class ViewModelTransformer {
    func transform(from models: [AlbumManagedModel]) -> ViewModel {
        guard
            models.isEmpty == false
        else {
            return .empty("There are no saved albums in your library")
        }
        
        let rows = models.map { model -> ViewModel.Section.Row in
            let imageURL = model.imageURL.map { URL(string: $0) } ?? nil
            return .init(title: model.title, imageURL: imageURL)
        }
        return .sections([.init(items: rows)])
    }
}
