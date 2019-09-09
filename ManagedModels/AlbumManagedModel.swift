import RealmSwift

public final class AlbumManagedModel: Object {
    dynamic var title: String = ""
    dynamic var imageURL: String?
    dynamic var url: ArtistManagedModel?
    var artist = LinkingObjects(fromType: ArtistManagedModel.self, property: "albums")
}
