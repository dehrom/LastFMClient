import Foundation
import ManagedModels

final class ViewModelTransformer {
    func transform(from models: [AlbumManagedModel]) -> ViewModel {
        print(models)
        return .empty
    }
}
